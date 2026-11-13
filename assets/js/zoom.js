// Animated photo zoom. Click or tap a photo: it grows to fill the screen (whole photo, never
// cropped) over a dimmed backdrop. Click, Escape or scroll: it shrinks back into place.
// Without JS the photo links still open the full image.
(() => {
    const script = document.currentScript;
    const openLabel = (script && script.dataset.open) || 'Enlarge photo';
    const closeLabel = (script && script.dataset.close) || 'Close enlarged photo';
    const reduce = window.matchMedia('(prefers-reduced-motion: reduce)');
    const MARGIN = 16;
    const DURATION = 380;
    const EASE = 'cubic-bezier(0.2, 0.8, 0.2, 1)';
    let current = null;

    const box = (r) => ({ left: r.left + 'px', top: r.top + 'px', width: r.width + 'px', height: r.height + 'px' });

    function fit(w, h) {
        const vw = window.innerWidth - MARGIN * 2;
        const vh = window.innerHeight - MARGIN * 2;
        const s = Math.min(vw / w, vh / h);
        const fw = w * s, fh = h * s;
        return { left: (window.innerWidth - fw) / 2, top: (window.innerHeight - fh) / 2, width: fw, height: fh };
    }

    function animate(el, from, to, opts) {
        if (reduce.matches) return Promise.resolve();
        return el.animate([from, to], { duration: DURATION, easing: EASE, fill: 'both', ...opts }).finished.catch(() => {});
    }

    async function open(trigger, img, bigSrc, w, h) {
        if (current) return;
        const rect = img.getBoundingClientRect();
        const end = fit(w, h);
        const backdrop = document.createElement('div');
        backdrop.className = 'zoom-backdrop';
        const clone = document.createElement('img');
        clone.className = 'zoom-image';
        clone.src = img.currentSrc || img.src;
        clone.alt = '';
        Object.assign(clone.style, box(rect));
        document.body.append(backdrop, clone);
        img.style.visibility = 'hidden';
        trigger.setAttribute('aria-expanded', 'true');
        const state = current = { trigger, img, backdrop, clone, closing: false };

        const big = new Image();
        big.src = bigSrc;
        big.decode().then(() => { if (!state.closing) clone.src = bigSrc; }).catch(() => {});

        Object.assign(clone.style, box(end)); // final state, so it stays put after the animation
        backdrop.style.opacity = '0.94';
        await Promise.all([
            animate(clone, box(rect), box(end)),
            animate(backdrop, { opacity: 0 }, { opacity: 0.94 }),
        ]);
        document.addEventListener('keydown', onKey, true);
        window.addEventListener('scroll', close, { passive: true });
        window.addEventListener('wheel', close, { passive: true });
        window.addEventListener('touchmove', close, { passive: true });
        window.addEventListener('resize', close);
        backdrop.addEventListener('click', close);
        clone.addEventListener('click', close);
    }

    async function close() {
        const s = current;
        if (!s || s.closing) return;
        s.closing = true;
        document.removeEventListener('keydown', onKey, true);
        window.removeEventListener('scroll', close);
        window.removeEventListener('wheel', close);
        window.removeEventListener('touchmove', close);
        window.removeEventListener('resize', close);
        const rect = s.img.getBoundingClientRect();
        const from = s.clone.getBoundingClientRect();
        Object.assign(s.clone.style, box(rect));
        s.backdrop.style.opacity = '0';
        await Promise.all([
            animate(s.clone, box(from), box(rect)),
            animate(s.backdrop, { opacity: 0.94 }, { opacity: 0 }),
        ]);
        s.img.style.visibility = '';
        s.clone.remove();
        s.backdrop.remove();
        s.trigger.setAttribute('aria-expanded', 'false');
        s.trigger.focus({ preventScroll: true });
        current = null;
    }

    function onKey(e) {
        if (e.key === 'Escape') { e.preventDefault(); close(); }
    }

    function activate(trigger, img, bigSrc, w, h) {
        const alt = img.alt;
        trigger.setAttribute('aria-expanded', 'false');
        trigger.setAttribute('aria-label', alt ? `${openLabel}: ${alt}` : openLabel);
        trigger.setAttribute('role', 'button');
        trigger.addEventListener('click', (e) => {
            if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey || e.button) return;
            e.preventDefault();
            open(trigger, img, bigSrc(), w(), h());
        });
        trigger.addEventListener('keydown', (e) => {
            if (e.key === ' ') { e.preventDefault(); trigger.click(); }
        });
    }

    // Photos in the photo, gallery and app-screens shortcodes
    document.querySelectorAll('a[data-zoom]').forEach((a) => {
        const img = a.querySelector('img');
        if (!img) return;
        activate(a, img, () => a.dataset.zoom, () => +a.dataset.zoomW, () => +a.dataset.zoomH);
    });

    // The cover photo at the top of a page (not the cards in lists, which link to their page)
    document.querySelectorAll('.post-single .entry-cover > img').forEach((img) => {
        img.classList.add('zoomable');
        img.tabIndex = 0;
        activate(img, img, () => img.src, () => img.naturalWidth, () => img.naturalHeight);
    });
    window.addEventListener('pagehide', () => { if (current) { current.img.style.visibility = ''; current.clone.remove(); current.backdrop.remove(); current = null; } });
})();

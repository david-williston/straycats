// App screenshot slideshow (layouts/_shortcodes/app-screens.html). Plays oldest to newest and
// loops. Without JS the slideshow stays hidden and only the grid shows. With reduced motion:
// no autoplay, no animation, manual stepping only.
(() => {
    const reduce = window.matchMedia('(prefers-reduced-motion: reduce)');
    const INTERVAL = 4000;

    document.querySelectorAll('.app-show').forEach((root) => {
        const slides = [...root.querySelectorAll('.app-show-slide')];
        if (slides.length < 1) return;
        const info = root.querySelector('.app-show-info');
        const dateEl = root.querySelector('.app-show-date');
        const capEl = root.querySelector('.app-show-caption');
        const controls = root.querySelector('.app-show-controls');
        const playBtn = root.querySelector('.app-show-play');
        const countEl = root.querySelector('.app-show-count');
        const live = root.querySelector('.app-show-live');
        const labels = { play: root.dataset.play, pause: root.dataset.pause };
        let index = 0;
        let playing = !reduce.matches;
        let hovering = false, focusing = false, hidden = document.hidden;
        let timer = null;

        root.tabIndex = 0;
        root.classList.add('is-ready');
        controls.hidden = false;

        function show(i, byUser) {
            index = (i + slides.length) % slides.length;
            slides.forEach((s, n) => { s.hidden = n !== index; });
            const s = slides[index];
            dateEl.textContent = s.dataset.date;
            capEl.textContent = s.dataset.caption;
            countEl.textContent = `${index + 1} / ${slides.length}`;
            if (!reduce.matches) {
                [s, info].forEach((el) => {
                    el.classList.remove('is-entering');
                    void el.offsetWidth; // restart the animation
                    el.classList.add('is-entering');
                });
            }
            if (byUser) live.textContent = `${s.dataset.caption}, ${s.dataset.date}. ${index + 1} / ${slides.length}`;
            const next = slides[(index + 1) % slides.length].querySelector('img');
            if (next) next.loading = 'eager';
        }

        function schedule() {
            clearTimeout(timer);
            if (playing && !reduce.matches && !hovering && !focusing && !hidden) {
                timer = setTimeout(() => { show(index + 1, false); schedule(); }, INTERVAL);
            }
        }

        function setPlaying(on) {
            playing = on;
            playBtn.classList.toggle('is-paused', !on);
            playBtn.setAttribute('aria-label', on ? labels.pause : labels.play);
            schedule();
        }

        function step(d) { show(index + d, true); schedule(); }

        root.querySelector('.app-show-prev').addEventListener('click', () => step(-1));
        root.querySelector('.app-show-next').addEventListener('click', () => step(1));
        playBtn.addEventListener('click', () => setPlaying(!playing));
        root.addEventListener('keydown', (e) => {
            if (e.target.closest('button')) { if (e.key !== 'ArrowLeft' && e.key !== 'ArrowRight') return; }
            if (e.key === 'ArrowLeft') { e.preventDefault(); step(-1); }
            else if (e.key === 'ArrowRight') { e.preventDefault(); step(1); }
        });
        root.addEventListener('pointerenter', (e) => { if (e.pointerType === 'mouse') { hovering = true; schedule(); } });
        root.addEventListener('pointerleave', () => { hovering = false; schedule(); });
        root.addEventListener('focusin', () => { focusing = true; schedule(); });
        root.addEventListener('focusout', (e) => { if (!root.contains(e.relatedTarget)) { focusing = false; schedule(); } });
        document.addEventListener('visibilitychange', () => { hidden = document.hidden; schedule(); });
        reduce.addEventListener('change', () => setPlaying(!reduce.matches));

        // Swipe on touch
        let x0 = null, y0 = 0;
        root.addEventListener('touchstart', (e) => { x0 = e.touches[0].clientX; y0 = e.touches[0].clientY; }, { passive: true });
        root.addEventListener('touchend', (e) => {
            if (x0 === null) return;
            const dx = e.changedTouches[0].clientX - x0, dy = e.changedTouches[0].clientY - y0;
            x0 = null;
            if (Math.abs(dx) > 40 && Math.abs(dx) > Math.abs(dy) * 1.5) step(dx < 0 ? 1 : -1);
        }, { passive: true });

        show(0, false);
        setPlaying(playing);
    });
})();

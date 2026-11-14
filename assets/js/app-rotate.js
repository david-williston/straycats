// Home page "now being built" card (layouts/_partials/app-progress.html): gently cross-fades the
// app screenshots, newest first, one a second. With reduced motion, or without JS, only the
// newest shows. Pauses while the tab is hidden or the card is hovered or focused.
(() => {
    const INTERVAL = 1000;
    if (!window.matchMedia('(prefers-reduced-motion: no-preference)').matches) return;

    document.querySelectorAll('[data-rotate]').forEach((root) => {
        const slides = [...root.querySelectorAll('.app-progress-slide')];
        if (slides.length < 2) return;
        let index = 0;
        let paused = false;

        const show = (i) => {
            index = i % slides.length;
            slides.forEach((s, n) => {
                const on = n === index;
                s.classList.toggle('is-active', on);
                const a = s.querySelector('a');
                if (on) { a.removeAttribute('tabindex'); a.removeAttribute('aria-hidden'); }
                else { a.tabIndex = -1; a.setAttribute('aria-hidden', 'true'); }
            });
        };
        const hold = (v) => () => { paused = v; };
        root.addEventListener('mouseenter', hold(true));
        root.addEventListener('mouseleave', hold(false));
        root.addEventListener('focusin', hold(true));
        root.addEventListener('focusout', hold(false));
        setInterval(() => { if (!paused && !document.hidden) show(index + 1); }, INTERVAL);
    });
})();

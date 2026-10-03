// Subtle motion helpers (see assets/css/extended/motion.css). Does nothing
// when the visitor prefers reduced motion.
(() => {
    if (!window.matchMedia('(prefers-reduced-motion: no-preference)').matches) return;

    // Fade images in once loaded (only those not already loaded).
    document.querySelectorAll('.post-content img, .entry-cover img').forEach((img) => {
        if (img.complete) return;
        img.classList.add('img-loading');
        const done = () => img.classList.remove('img-loading');
        img.addEventListener('load', done, { once: true });
        img.addEventListener('error', done, { once: true });
    });

    // Reveal blocks as they scroll into view. Elements already on screen are left alone.
    if (!('IntersectionObserver' in window)) return;
    const targets = document.querySelectorAll(
        '.post-entry:not(.first-entry), .post-content > figure, .post-content > h2, .post-content > table, .respond, .post-footer, .paginav'
    );
    const observer = new IntersectionObserver((entries) => {
        for (const entry of entries) {
            if (!entry.isIntersecting) continue;
            entry.target.classList.add('is-visible');
            observer.unobserve(entry.target);
        }
    }, { rootMargin: '0px 0px -8% 0px' });
    targets.forEach((el) => {
        if (el.getBoundingClientRect().top < window.innerHeight) return;
        el.classList.add('reveal');
        observer.observe(el);
    });
})();

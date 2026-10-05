// Speed buttons for the listen shortcode (layouts/_shortcodes/listen.html).
document.querySelectorAll('.listen').forEach((player) => {
    const audio = player.querySelector('audio');
    const buttons = player.querySelectorAll('button[data-rate]');
    const show = () => buttons.forEach((b) => {
        b.setAttribute('aria-pressed', String(Number(b.dataset.rate) === audio.playbackRate));
    });
    buttons.forEach((button) => button.addEventListener('click', () => {
        audio.playbackRate = Number(button.dataset.rate);
        audio.defaultPlaybackRate = audio.playbackRate; // keep the speed after seeking or replaying
    }));
    audio.addEventListener('ratechange', show); // also follows the browser's own speed menu
    show();
});

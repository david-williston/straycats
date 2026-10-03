import * as params from '@params';

const resList = document.getElementById('searchResults');
const sInput = document.getElementById('searchInput');
const searchBox = document.getElementById('searchbox');

let fuse;
let currentElement = null;
let firstResult = null;
let lastResult = null;

const defaultFuseOptions = {
    distance: 100,
    threshold: 0.4,
    ignoreLocation: true,
    keys: ['title', 'permalink', 'summary', 'content']
};

const buildFuseOptions = () => {
    if (!params.fuseOpts) {
        return defaultFuseOptions;
    }

    return {
        isCaseSensitive: params.fuseOpts.iscasesensitive ?? false,
        includeScore: params.fuseOpts.includescore ?? false,
        includeMatches: params.fuseOpts.includematches ?? false,
        minMatchCharLength: params.fuseOpts.minmatchcharlength ?? 1,
        shouldSort: params.fuseOpts.shouldsort ?? true,
        findAllMatches: params.fuseOpts.findallmatches ?? false,
        keys: params.fuseOpts.keys ?? defaultFuseOptions.keys,
        location: params.fuseOpts.location ?? 0,
        threshold: params.fuseOpts.threshold ?? defaultFuseOptions.threshold,
        distance: params.fuseOpts.distance ?? defaultFuseOptions.distance,
        ignoreLocation: params.fuseOpts.ignorelocation ?? defaultFuseOptions.ignoreLocation
    };
};

const debounce = (fn, delay) => {
    let timeout;
    return (...args) => {
        clearTimeout(timeout);
        timeout = window.setTimeout(() => fn(...args), delay);
    };
};

const reset = () => {
    currentElement = null;
    firstResult = null;
    lastResult = null;
    resList.innerHTML = '';
    sInput.value = '';
    sInput.focus();
};

const setActiveResult = (element) => {
    document.querySelectorAll('.focus').forEach((item) => item.classList.remove('focus'));

    if (!element) {
        return;
    }

    element.focus();
    element.parentElement?.classList.add('focus');
    currentElement = element;
};

// --- Result previews (Stray Cats override of PaperMod's fastsearch.js) ---

const PREVIEW_LENGTH = 180;

// Lowercase and strip accents so "opinion" matches "opinión". Returns the folded
// string plus a map from each folded index back to the original string index.
const fold = (text) => {
    let folded = '';
    const map = [];
    for (let i = 0; i < text.length; i++) {
        const f = text[i].normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase();
        for (let j = 0; j < f.length; j++) {
            folded += f[j];
            map.push(i);
        }
    }
    return { folded, map };
};

const queryTerms = (query) => [...new Set(fold(query).folded.split(/\s+/).filter((t) => t.length > 1))];

// Original-string [start, end) ranges where any term occurs, sorted and merged.
const findRanges = (text, terms) => {
    const { folded, map } = fold(text);
    const ranges = [];
    for (const term of terms) {
        let at = folded.indexOf(term);
        while (at !== -1) {
            ranges.push([map[at], map[at + term.length - 1] + 1]);
            at = folded.indexOf(term, at + term.length);
        }
    }
    ranges.sort((a, b) => a[0] - b[0]);
    const merged = [];
    for (const r of ranges) {
        const last = merged[merged.length - 1];
        if (last && r[0] <= last[1]) last[1] = Math.max(last[1], r[1]);
        else merged.push([...r]);
    }
    return merged;
};

// Append text to parent, wrapping matched ranges in <mark>.
const appendHighlighted = (parent, text, terms) => {
    let pos = 0;
    for (const [start, end] of findRanges(text, terms)) {
        parent.appendChild(document.createTextNode(text.slice(pos, start)));
        const mark = document.createElement('mark');
        mark.textContent = text.slice(start, end);
        parent.appendChild(mark);
        pos = end;
    }
    parent.appendChild(document.createTextNode(text.slice(pos)));
};

// A window of the page text around the first match, or the summary if the
// (fuzzy) match isn't literally in the content.
const previewText = (item, terms) => {
    const content = (item.content || '').replace(/\s+/g, ' ').trim();
    const first = findRanges(content, terms)[0];
    if (!first) {
        const summary = (item.summary || content).replace(/\s+/g, ' ').trim();
        return summary.length > PREVIEW_LENGTH ? summary.slice(0, PREVIEW_LENGTH).replace(/\s+\S*$/, '') + ' …' : summary;
    }
    let start = Math.max(0, first[0] - Math.floor(PREVIEW_LENGTH / 3));
    let end = Math.min(content.length, start + PREVIEW_LENGTH);
    if (start > 0) start = content.indexOf(' ', start) + 1 || start;
    if (end < content.length) end = content.lastIndexOf(' ', end) > first[1] ? content.lastIndexOf(' ', end) : end;
    return (start > 0 ? '… ' : '') + content.slice(start, end) + (end < content.length ? ' …' : '');
};

const renderResults = (results, query = '') => {
    if (!Array.isArray(results) || results.length === 0) {
        resList.innerHTML = '';
        firstResult = lastResult = currentElement = null;
        return;
    }

    const terms = queryTerms(query);
    const fragment = document.createDocumentFragment();

    for (const result of results) {
        const { item } = result;
        const li = document.createElement('li');

        const body = document.createElement('div');
        body.className = 'search-result';

        const meta = [item.section, item.date].filter(Boolean).join(' · ');
        if (meta) {
            const metaEl = document.createElement('div');
            metaEl.className = 'search-result-meta';
            metaEl.textContent = meta;
            body.appendChild(metaEl);
        }

        const title = document.createElement('div');
        title.className = 'search-result-title';
        appendHighlighted(title, item.title, terms);
        body.appendChild(title);

        const preview = previewText(item, terms);
        if (preview) {
            const p = document.createElement('p');
            p.className = 'search-result-preview';
            appendHighlighted(p, preview, terms);
            body.appendChild(p);
        }

        const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
        svg.setAttribute('width', '24');
        svg.setAttribute('height', '24');
        svg.setAttribute('viewBox', '0 0 24 24');
        svg.setAttribute('fill', 'none');
        svg.setAttribute('stroke', 'currentColor');
        svg.setAttribute('stroke-width', '2');
        svg.setAttribute('stroke-linecap', 'round');
        svg.setAttribute('stroke-linejoin', 'round');
        svg.classList.add('feather', 'feather-chevrons-right');
        svg.innerHTML = '<polyline points="13 17 18 12 13 7"></polyline><polyline points="6 17 11 12 6 7"></polyline>';

        const link = document.createElement('a');
        link.className = 'entry-link';
        link.href = item.permalink;
        link.setAttribute('aria-label', item.title);

        li.appendChild(body);
        li.appendChild(svg);
        li.appendChild(link);
        fragment.appendChild(li);
    }

    resList.innerHTML = '';
    resList.appendChild(fragment);
    firstResult = resList.firstElementChild;
    lastResult = resList.lastElementChild;
};

const performSearch = () => {
    if (!fuse) {
        return;
    }

    const query = sInput.value.trim();
    if (!query) {
        renderResults([]);
        return;
    }

    const searchOptions = params.fuseOpts?.limit ? { limit: params.fuseOpts.limit } : undefined;
    const results = searchOptions ? fuse.search(query, searchOptions) : fuse.search(query);
    renderResults(results, query);
};

const initSearch = async () => {
    if (!sInput || !resList) {
        return;
    }

    sInput.disabled = false;
    sInput.focus();

    try {
        const response = await fetch('../index.json');
        if (!response.ok) {
            throw new Error(`Search index load failed: ${response.status}`);
        }

        const data = await response.json();
        if (data) {
            fuse = new Fuse(data, buildFuseOptions());
        }
    } catch (error) {
        console.error(error);
    }
};

window.addEventListener('load', initSearch);

sInput?.addEventListener('input', debounce(performSearch, 150));

sInput?.addEventListener('search', () => {
    if (!sInput.value) {
        reset();
    }
});

document.addEventListener('keydown', (event) => {
    const { key } = event;
    const active = document.activeElement;
    const isInSearchBox = searchBox?.contains(active);

    if (key === 'Escape') {
        reset();
        return;
    }

    if (!firstResult || !isInSearchBox) {
        return;
    }

    if (key === 'ArrowDown') {
        event.preventDefault();

        if (active === sInput) {
            setActiveResult(firstResult.querySelector('.entry-link'));
        } else if (active?.parentElement !== lastResult) {
            setActiveResult(active?.parentElement?.nextElementSibling?.querySelector('.entry-link'));
        }
    } else if (key === 'ArrowUp') {
        event.preventDefault();

        if (active?.parentElement === firstResult) {
            setActiveResult(sInput);
        } else if (active !== sInput) {
            setActiveResult(active?.parentElement?.previousElementSibling?.querySelector('.entry-link'));
        }
    } else if (key === 'ArrowRight') {
        if (active?.matches?.('.entry-link')) {
            active.click();
        }
    }
});

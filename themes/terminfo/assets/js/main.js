(function () {
  'use strict';

  // --------------------------------------------------------
  // Detect $TERM and update install one-liner
  // --------------------------------------------------------
  function detectTerm() {
    const box = document.getElementById('install-box');
    if (!box) return;

    const code = box.querySelector('code');
    const label = box.querySelector('.install-label-text');
    const detected = (navigator.userAgentData?.platform || navigator.platform || '').toLowerCase();

    // Try to infer a common terminal from UA (very rough)
    let term = '';
    if (detected.includes('mac')) term = 'xterm-256color';
    else if (detected.includes('linux')) term = 'xterm-256color';
    else term = 'xterm-256color';

    // If the user is actually viewing in a terminal-like browser we can't read $TERM,
    // so we show a generic fallback and mention detection.
    const oneLiner = `curl -fsSL https://yourusername.github.io/terminfo-collection/install.sh | bash -s -- ${term}`;
    if (code) code.textContent = oneLiner;
    if (label) label.textContent = `Detected: ${term}`;
  }

  // --------------------------------------------------------
  // Copy button
  // --------------------------------------------------------
  function initCopyButtons() {
    document.querySelectorAll('.copy-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const target = btn.closest('.code-block')?.querySelector('code');
        if (!target) return;
        navigator.clipboard.writeText(target.textContent).then(() => {
          const original = btn.textContent;
          btn.textContent = 'Copied!';
          btn.classList.add('copied');
          setTimeout(() => {
            btn.textContent = original;
            btn.classList.remove('copied');
          }, 1500);
        });
      });
    });
  }

  // --------------------------------------------------------
  // Live search on terminfo list
  // --------------------------------------------------------
  function initSearch() {
    const input = document.getElementById('terminfo-search');
    const list = document.getElementById('terminfo-list');
    if (!input || !list) return;

    const items = list.querySelectorAll('.terminfo-item');

    input.addEventListener('input', () => {
      const q = input.value.toLowerCase().trim();
      items.forEach(item => {
        const name = item.dataset.name || '';
        const text = item.textContent.toLowerCase();
        const match = !q || name.includes(q) || text.includes(q);
        item.classList.toggle('hidden', !match);
      });
    });
  }

  // --------------------------------------------------------
  // Init
  // --------------------------------------------------------
  document.addEventListener('DOMContentLoaded', () => {
    detectTerm();
    initCopyButtons();
    initSearch();
  });
})();

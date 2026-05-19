(function () {
  'use strict';

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
    initCopyButtons();
    initSearch();
  });
})();

(function () {
  'use strict';

  // --------------------------------------------------------
  // Typewriter effect for terminal demo
  // --------------------------------------------------------
  function initTypewriter() {
    const target = document.querySelector('.type-target');
    if (!target) return;

    const raw = target.dataset.terms || '';
    const terms = raw.split(',').filter(Boolean);
    if (!terms.length) return;

    let termIndex = 0;
    let charIndex = 0;
    let isDeleting = false;
    const typeSpeed = 100;
    const deleteSpeed = 50;
    const pauseAfterType = 2000;
    const pauseAfterDelete = 300;

    function tick() {
      const current = terms[termIndex];
      if (isDeleting) {
        charIndex--;
        target.textContent = current.slice(0, charIndex);
        if (charIndex <= 0) {
          isDeleting = false;
          termIndex = (termIndex + 1) % terms.length;
          setTimeout(tick, pauseAfterDelete);
          return;
        }
        setTimeout(tick, deleteSpeed);
      } else {
        charIndex++;
        target.textContent = current.slice(0, charIndex);
        if (charIndex >= current.length) {
          isDeleting = true;
          setTimeout(tick, pauseAfterType);
          return;
        }
        setTimeout(tick, typeSpeed);
      }
    }

    tick();
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
    initTypewriter();
    initCopyButtons();
    initSearch();
  });
})();

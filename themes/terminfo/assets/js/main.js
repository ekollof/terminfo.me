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

    // Respect reduced motion: show static first term, no animation or blinking cursor
    const prefersReduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (prefersReduced) {
      target.textContent = terms[0];
      // Hide the blinking cursor element if present (CSS also disables animation)
      const cursor = document.querySelector('.type-cursor');
      if (cursor) cursor.style.display = 'none';
      return;
    }

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
        let textToCopy = btn.dataset.copyText;

        if (!textToCopy) {
          const target = btn.closest('.code-block')?.querySelector('code');
          if (target) textToCopy = target.textContent;
        }

        if (!textToCopy) return;

        navigator.clipboard.writeText(textToCopy).then(() => {
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
  // Live search on terminfo list (enhanced with clear, count, empty state)
  // --------------------------------------------------------
  function initSearch() {
    const input = document.getElementById('terminfo-search');
    const list = document.getElementById('terminfo-list');
    if (!input || !list) return;

    const items = list.querySelectorAll('.terminfo-item');
    const total = items.length;

    // Find or create wrapper (we added .search-wrapper in templates for positioning)
    const wrapper = input.closest('.search-wrapper') || input.parentElement;

    // Create + inject clear button
    const clearBtn = document.createElement('button');
    clearBtn.type = 'button';
    clearBtn.className = 'search-clear';
    clearBtn.setAttribute('aria-label', 'Clear search');
    clearBtn.textContent = '×';
    wrapper.appendChild(clearBtn);

    // Create status line (count / empty help)
    const status = document.createElement('p');
    status.className = 'search-status';
    status.setAttribute('aria-live', 'polite');
    // Insert after the wrapper (before the list)
    wrapper.after(status);

    function updateSearch() {
      const q = input.value.toLowerCase().trim();
      let visible = 0;

      items.forEach(item => {
        const name = item.dataset.name || '';
        const text = item.textContent.toLowerCase();
        const match = !q || name.includes(q) || text.includes(q);
        item.classList.toggle('hidden', !match);
        if (match) visible++;
      });

      // Clear button visibility
      clearBtn.style.display = q ? 'block' : 'none';

      // Status text
      if (!q) {
        status.textContent = '';
        status.style.display = 'none';
      } else if (visible === 0) {
        status.innerHTML = `No matches for <strong>${q}</strong>. Try a terminal name like <em>kitty</em> or <em>alacritty</em>.`;
        status.style.display = 'block';
      } else {
        status.textContent = `${visible} of ${total} entries`;
        status.style.display = 'block';
      }
    }

    input.addEventListener('input', updateSearch);

    clearBtn.addEventListener('click', () => {
      input.value = '';
      updateSearch();
      input.focus();
    });

    // Initial state
    updateSearch();
  }

  // --------------------------------------------------------
  // Per-entry "install one-liner" copy buttons in lists
  // --------------------------------------------------------
  function initInstallOneLiners() {
    const base = 'curl -fsSL https://terminfo.me/install.sh | sh -s --';
    document.querySelectorAll('.copy-install-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const name = btn.dataset.name || '';
        const cmd = `${base} ${name}`;
        navigator.clipboard.writeText(cmd).then(() => {
          const orig = btn.textContent;
          btn.textContent = 'copied!';
          btn.classList.add('copied');
          setTimeout(() => {
            btn.textContent = orig;
            btn.classList.remove('copied');
          }, 1400);
        });
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
    initInstallOneLiners();
  });
})();

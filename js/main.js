document.addEventListener('DOMContentLoaded', () => {
  // Mobile menu toggle with accessibility
  const btn = document.getElementById('mobile-menu-btn');
  const menu = document.getElementById('mobile-menu');
  if (btn && menu) {
    btn.addEventListener('click', () => {
      menu.classList.toggle('hidden');
      const expanded = !menu.classList.contains('hidden');
      btn.setAttribute('aria-expanded', expanded);
    });
  }

  // Gallery lightbox
  const lightbox = document.getElementById('lightbox');
  const lightboxImg = document.getElementById('lightbox-img');
  if (lightbox && lightboxImg) {
    document.querySelectorAll('.gallery-item').forEach(item => {
      item.addEventListener('click', () => {
        const img = item.querySelector('img');
        if (img) {
          lightboxImg.src = img.src;
          lightboxImg.alt = img.alt;
          lightbox.classList.remove('hidden');
          lightbox.classList.add('flex');
        }
      });
    });

    lightbox.addEventListener('click', () => {
      lightbox.classList.add('hidden');
      lightbox.classList.remove('flex');
    });

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && !lightbox.classList.contains('hidden')) {
        lightbox.classList.add('hidden');
        lightbox.classList.remove('flex');
      }
    });
  }
});

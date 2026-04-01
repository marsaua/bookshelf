document.addEventListener('turbo:load', () => {
  if (typeof Swiper === 'undefined' || !document.querySelector('.swiper')) return

  new Swiper('.swiper', {
    slidesPerView: 4,
    spaceBetween: 3,
    autoplay: { delay: 3000 },
    loop: true,
    pagination: { el: '.swiper-pagination' },
  })
})

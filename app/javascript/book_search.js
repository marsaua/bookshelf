document.addEventListener('turbo:load', () => {
  const input = document.getElementById('book-search')
  const results = document.getElementById('search-results')
  if (!input || !results) return

  input.addEventListener('input', async () => {
    if (input.value.length < 3) return

    const res = await fetch(`/books/search?query=${encodeURIComponent(input.value)}`)
    const books = await res.json()

    results.innerHTML = books.map(book => `
      <div class="search-result-item flex items-center gap-3 p-3 rounded-lg border border-[#e0d0bc] cursor-pointer hover:bg-[#fdf8f3] transition"
           onclick="selectBook(${JSON.stringify(book).replace(/"/g, '&quot;')})">
        <img src="${book.image || ''}" class="w-10 h-14 object-cover rounded-sm shrink-0 bg-gray-100" onerror="this.style.display='none'">
        <div>
          <p class="text-sm font-semibold text-[#3b2a1a]">${book.title}</p>
          <p class="text-xs text-gray-500">${book.author || ''}</p>
        </div>
      </div>
    `).join('')
  })

  window.selectBook = (book) => {
    document.querySelector('[name="book[title]"]').value = book.title
    document.querySelector('[name="book[author]"]').value = book.author
    document.querySelector('[name="book[description]"]').value = book.description
    document.querySelector('[name="book[cover_url]"]').value = book.image
    document.querySelector('[name="book[category]"]').value = book.category || ''
    document.querySelector('[name="book[page_count]"]').value = book.page_count || ''
    document.querySelector('[name="book[language]"]').value = book.language || ''
    document.querySelector('[name="book[publisher]"]').value = book.publisher || ''

    results.innerHTML = `
      <div class="flex items-center gap-3 p-3 rounded-lg bg-green-50 border border-green-200">
        <img src="${book.image || ''}" class="w-10 h-14 object-cover rounded-sm shrink-0" onerror="this.style.display='none'">
        <div>
          <p class="text-sm font-semibold text-[#3b2a1a]">✅ ${book.title}</p>
          <p class="text-xs text-gray-500">Ready to add</p>
        </div>
      </div>
    `
  }
})

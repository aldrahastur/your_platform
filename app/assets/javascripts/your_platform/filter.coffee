# The global search field may be used to filter the current content.
#
$(document).on 'keyup', 'header #search, #header_search #query.find_and_filter, input.filter_query', ->
  query = $(this).val()

  $('.filter-hidden').removeClass('filter-hidden')

  $('.datatable').each ->
    datatable = $(this).DataTable()
    datatable.search(query).draw()

  App.vue_app.$root.$emit("search", query)

  for str in query.split(" ")
    for selector in [".box", "li", "tbody tr", ".filterable"]
      $("#content " + selector).each ->
        element = $(this)
        unless element.text().toUpperCase().indexOf(str.toUpperCase()) >= 0
          element.addClass('filter-hidden')


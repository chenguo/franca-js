module.exports =

  basic:
    facet:
      field: 'category'

  withLimit:
    facet:
      field: 'category'
    options:
      limit: 100

  countAsc:
    facet:
      field: 'category'
      sort: 1

  byValue:
    facet:
      field: 'category'
      sort: 'value'

  valueDesc:
    facet:
      field: 'category'
      sort:
        value: 'desc'

  withQuery:
    facet:
      field: 'category'
      sort: 'descending'
    query:
      field: 'difficulty'
      match: 'high'

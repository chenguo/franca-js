foo1 = name: 'Foo', distance: 1, rating: 50
foo2 = name: 'Foo', distance: 2, nested: {val: 3}
foo3 = name: 'Foo', distance: 3, nested: {val: 4}
bar1 = name: 'Bar', distance: 1, nested: {val: 4}
bar2 = name: 'Bar', distance: 2, rating: 25
bar3 = name: 'Bar', distance: 3
baz1 = name: 'Baz', distance: 1
baz2 = name: 'Baz', distance: 2, rating: 60, nested: {val: 0}
baz3 = name: 'Baz', distance: 3, rating: 70, nested: {val: 8}


module.exports =

  rows: [ foo1, foo2, foo3, bar1, bar2, bar3, baz1, baz2, baz3 ]

  foo1: foo1
  foo2: foo2
  foo3: foo3
  bar1: bar1
  bar2: bar2
  bar3: bar3
  baz1: baz1
  baz2: baz2
  baz3: baz3

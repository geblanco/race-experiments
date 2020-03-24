/*
  given data like:
    set1: [bert, multibert],
    set2: [eng, spa],
    set3: [2013, 2014],
    exceptions: [spa-2013],
    format: '%s-%s'
  generate all combinations:
    [bert-eng-2013, bert-eng-2014, bert-spa-2014, multibert-eng-2013, multibert-eng-2014, multibert-spa-2014]
*/
{
  _joinWithFormat(formatStr, items):: std.format(formatStr, items),
  _combineItemWithSet(formatStr, item1, set2, use_exceptions, exceptions):: [
    self._joinWithFormat(formatStr, [item1, item2])
    for item2 in set2
    if !use_exceptions || !(std.member(exceptions, self._joinWithFormat(formatStr, [item1, item2])))
  ],
  _removeLastElem(array):: std.reverse(
    std.filter(
      function(elem) elem != null,
      std.mapWithIndex(function(idx, elem) if idx == 0 then null else elem, std.reverse(array))
    )
  ),
  bashExport(var, val):: 'export ' + std.asciiUpper(var) + '=' + val,
  fieldsToBash(obj):: std.join('\n', [self.bashExport(var, obj[var]) for var in std.objectFields(obj)]),
  getStringSegment(str, sep, segment):: std.split(str, sep)[segment],
  trimExt(str):: std.join('.', self._removeLastElem(std.split(str, '.'))),
  generateCombinationsTwoSets(set1, set2, formatStr):: std.flattenArrays([
    self._combineItemWithSet(formatStr, item1, set2, false, [])
    for item1 in set1
  ]),
  generateCombinations(set1, set2, set3, exceptions, formatStr):: std.flattenArrays([
    self._combineItemWithSet(
      formatStr,
      item1,
      std.flattenArrays([
        self._combineItemWithSet(formatStr, item2, set3, true, exceptions)
        for item2 in set2
      ]),
      false,
      exceptions
    )
    for item1 in set1
  ]),
}

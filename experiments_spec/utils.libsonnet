{
  bashExport(var, val):: 'export ' + std.asciiUpper(var) + '=' + val,
  fieldsToBash(obj):: std.join('\n', [self.bashExport(var, obj[var]) for var in std.objectFields(obj)]),
}
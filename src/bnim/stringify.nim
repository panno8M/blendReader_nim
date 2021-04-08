import strformat
import strutils
import sugar
import sequtils
import core
import types

proc `$`*[N](self: ptr array[N, byte]): string =
  self[].map(b => $b.toHex(2)).join(" ")

proc `$`*[N](self: seq[ptr array[N, byte]]): string =
  self.map(bytesPtr => $bytesPtr).join("\n")

proc `$`*(self: FileHeader): string =
  &"""# File Header
  * version: {self.version[0]}.{self.version[1..2]}
  * pointer length: {self.pointerSize}byte
  * endian: {self.endian}"""
proc `$`*(self: BlockHeader): string =
  &"""# {self.code}
  * size: {self.size}
  * SDNA index: {self.sdnaIdx}
  * count: {self.count}"""

proc `$`*(self: Dna): string =
  self.structures.mapIt(&"""type {self.types[it.typeIdx].name}  [{self.types[it.typeIdx].len}byte]
""" & it.fields.map(f =>
      &"  {self.names[f.nameIdx]}: {self.types[f.typeIdx].name}  [{self.types[f.typeIdx].len}byte]").join(
          "\n")).join("\n\n")

proc `$`*(self: Blend): string =
  let titleDeco = "=".repeat(int((88 - self.path.len)/2)).join()
  &"""{titleDeco} {self.path} {titleDeco}
{$self.header}"""

proc `$`*(self: ptr Mvert): string =
  &"""co: {self[].co}
no: {self[].no}
flag: {self[].flag}
weight: {self[].bweight}"""
proc `$`*(self: seq[ptr MVert]): string =
  for i in 0..<self.len:
    result &= &"""MVert{i}:
{($self[i]).indent(2)}
"""
proc `$`*(self: MVert): string =
  &"""co: {self.co}
no: {self.no}
flag: {self.flag}
weight: {self.bweight}"""
proc `$`*(self: seq[MVert]): string =
  for i in 0..<self.len:
    result &= &"""MVert{i}:
{($self[i]).indent(2)}
"""

proc `$`*(self: ptr MEdge): string =
  &"""v1: {self[].v1}
v2: {self[].v2}
crease: {self[].crease}
bweight: {self[].bweight}
flag: {self[].flag}"""
proc `$`*(self: seq[ptr MEdge]): string =
  for i in 0..<self.len:
    result &= &"""MVEdge{i}:
{($self[i]).indent(2)}
"""
proc `$`*(self: MEdge): string =
  &"""v1: {self.v1}
v2: {self.v2}
crease: {self.crease}
bweight: {self.bweight}
flag: {self.flag}"""
proc `$`*(self: seq[MEdge]): string =
  for i in 0..<self.len:
    result &= &"""MVEdge{i}:
{($self[i]).indent(2)}
"""

proc `$`*(self: ptr MPoly): string =
  &"""loop start: {self[].loopstart}
total loop: {self[].totloop}
flag: {self[].flag.toBin(16)}
mat nr:{self[].mat_nr}"""
proc `$`*(self: seq[ptr MPoly]): string =
  for i in 0..<self.len:
    result &= &"""MPoly{i}:
{($self[i]).indent(2)}
"""
proc `$`*(self: MPoly): string =
  &"""loop start: {self.loopstart}
total loop: {self.totloop}
flag: {self.flag.toBin(16)}
mat nr:{self.mat_nr}"""
proc `$`*(self: seq[MPoly]): string =
  for i in 0..<self.len:
    result &= &"""MPoly{i}:
{($self[i]).indent(2)}
"""

proc `$`*(self: ptr MLoop): string =
  &"""vert index: {self[].v}
edge index: {self[].e}"""
proc `$`*(self: seq[ptr MLoop]): string =
  for i in 0..<self.len:
    result &= &"""MLoop{i}:
{($self[i]).indent(2)}
"""
proc `$`*(self: MLoop): string =
  &"""vert index: {self.v}
edge index: {self.e}"""
proc `$`*(self: seq[MLoop]): string =
  for i in 0..<self.len:
    result &= &"""MLoop{i}:
{($self[i]).indent(2)}
"""

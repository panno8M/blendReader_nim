import sequtils, strutils, tables

type
  Vaddr* = uint64

type FileHeader* = object
  fileIdentifier*: array[7, cchar]
  ptrSize*: cchar
  endian*: cchar
  version: array[3, cchar]
proc version*(self: FileHeader): string = self.version.join
proc pointerSize*(self: FileHeader): int = (if self.ptrSize == '-': 8 else: 4)

type
  DSfield* = tuple[typeIdx, nameIdx: int16]
  DnaStructure* = object
    typeIdx*: int16
    fields*: seq[DSfield]

  SDSfield* = tuple[name: string; len: int16]
  SDSnamedField* = tuple[fieldName, fieldType: string; fieldLen: int16]
  StringifiedDnaStructure* = object
    strcType*: SDSfield
    fields*: seq[SDSnamedField]

  Dna* = object
    names*: seq[string]
    types*: seq[tuple[name: string; len: int16]]
    structures*: seq[DnaStructure]

type BlockHeader* = object
  code: array[4, cchar]
  size*: int32
  memAddr*: Vaddr
  sdnaIdx*: int32
  count*: int32
proc code*(self: BlockHeader): string = self.code.join

type
  Blend* = ref object
    file*: File
    path*: string
    header*: FileHeader
    blockHeaders*: seq[BlockHeader]
    dna*: Dna
    memAddrTable*: Table[Vaddr, pointer]
    addrToBhTable*: Table[Vaddr, ptr BlockHeader]



proc parseStr*(self: DnaStructure; blend: Blend): StringifiedDnaStructure =
  template dna(): Dna = blend.dna
  result = StringifiedDnaStructure(
    strcType: (dna.types[self.typeIdx].name, dna.types[self.typeIdx].len),
    fields: newSeq[SDSnamedField](self.fields.len))
  for i, f in self.fields:
    result.fields[i] = (dna.names[f.nameIdx], dna.types[f.typeIdx].name,
        dna.types[f.typeIdx].len)
proc getStrc*(sdnaIdx: int; blend: Blend): DnaStructure =
  blend.dna.structures[sdnaIdx]
proc getStrcS*(sdnaIdx: int; blend: Blend): StringifiedDnaStructure =
  sdnaIdx.getStrc(blend).parseStr(blend)
proc getStrcType*(sdnaIdx: int; blend: Blend): SDSfield =
  sdnaIdx.getStrc(blend).parseStr(blend).strcType

proc accessSingle*[T](memAddr: Vaddr; blend: Blend): ptr T =
  cast[ptr T](blend.memAddrTable[memAddr])

proc access*[T](memAddr: Vaddr; blend: Blend): seq[ptr T] =
  let count = blend.addrToBhTable[memAddr][].count
  template shift(p: pointer; offset: int): ptr T =
    cast[ptr T](cast[uint64](p) + uint64(offset))
  result.setLen(count)
  for i in 0..<count:
    result[i] = blend.memAddrTable[memAddr].shift(sizeof(T) * i)


# *activate blend sugar ==================================================
var activated: Blend
template activate*(self: Blend) = activated = self
template disactivate*(self: Blend) = activated = nil
template parseStr*(self: DnaStructure): StringifiedDnaStructure = self.parseStr(activated)
template getStrc*(sdnaIdx: int): DnaStructure = sdnaIdx.getStrc(activated)
template getStrcS*(sdnaIdx: int): StringifiedDnaStructure = sdnaIdx.getStrcS(activated)
template getStrcType*(sdnaIdx: int): SDSfield = sdnaIdx.getStrcType(activated)

proc accessSingle*[T](memAddr: Vaddr): ptr T = accessSingle[T](memAddr, activated)
proc access*[T](memAddr: Vaddr): seq[ptr T] = access[T](memAddr, activated)

# * ============================================================

proc openBlend*(path: string): Blend =
  template r(): Blend = result
  template f(): File = r.file
  template h(): FileHeader = r.header
  template bhs(): seq[BlockHeader] = r.blockHeaders
  template d(): Dna = r.dna

  r = Blend(path: path)
  f = path.open()

  r.activate()

  doAssert f.readBuffer(h.addr, 12) == 12
  doAssert h.fileIdentifier == "BLENDER"

  doAssert h.ptrSize == '-', "This library only supports 64bit pointer."
  doAssert h.endian == 'v', "This library only supports little endian."

  r.memAddrTable = initTable[Vaddr, pointer]()
  r.addrToBhTable = initTable[Vaddr, ptr BlockHeader]()

  bhs = newSeq[BlockHeader]()
  while true:
    var bh = BlockHeader()
    discard f.readBuffer(bh.addr, 24)

    # *<read DNA block>
    if bh.code == "DNA1":
      d = Dna()
      var
        bufc4: array[4, char]
        bufi32: int32
        bufi16: int16
      ###############################
      discard f.readBuffer(bufc4.addr, 4)
      doAssert bufc4 == "SDNA"
      ###############################

      ###############################
      discard f.readBuffer(bufc4.addr, 4)
      doAssert bufc4 == "NAME"

      discard f.readBuffer(bufi32.addr, 4)
      d.names = newSeq[string](bufi32)
      for i in 0..<d.names.len:
        while true:
          let c = f.readChar()
          if c == '\x0':
            break
          d.names[i] &= c
      ###############################

      ###############################
      discard f.readBuffer(bufc4.addr, 4)
      doAssert bufc4 == "TYPE"

      discard f.readBuffer(bufi32.addr, 4)
      d.types = newSeq[tuple[name: string; len: int16]](bufi32)
      for i in 0..<d.types.len:
        while true:
          let c = f.readChar()
          if c == '\x0':
            break
          d.types[i].name &= c
      ###############################

      discard f.readChar()

      ###############################
      discard f.readBuffer(bufc4.addr, 4)
      doAssert bufc4 == "TLEN"

      for i in 0..<d.types.len:
        discard f.readBuffer(d.types[i].len.addr, 2)
      ###############################

      discard f.readChar()
      discard f.readChar()

      ###############################
      discard f.readBuffer(bufc4.addr, 4)
      doAssert bufc4 == "STRC"

      discard f.readBuffer(bufi32.addr, 4)
      d.structures = newSeq[DnaStructure](bufi32)
      for i in 0..<d.structures.len:
        var strc = DnaStructure()
        discard f.readBuffer(strc.typeIdx.addr, 2)
        discard f.readBuffer(bufi16.addr, 2)
        strc.fields = newSeq[tuple[typeIdx, nameIdx: int16]](bufi16)
        for j in 0..<bufi16:
          discard f.readBuffer(strc.fields[j].addr, 4)
        d.structures[i] = strc
      ###############################
      break
    # *</read DNA block>
    else:
      r.memAddrTable[bh.memAddr] = alloc(bh.size)
      discard f.readBuffer(r.memAddrTable[bh.memAddr], bh.size)
      bhs.add bh
      r.addrToBhTable[bh.memAddr] = bhs[bhs.high].addr


  r.file.close()

proc closeBlend*(blend: Blend) =
  for header in blend.blockHeaders:
    blend.memAddrTable[header.memAddr].dealloc()

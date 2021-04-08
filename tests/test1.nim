# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import sequtils
import blendReader
test "can read .blend":
  block:
    let blend = openBlend("cube.blend")
    defer:
      blend.closeBlend()

    for header in blend.blockHeaders:
      if header.sdnaIdx.getStrcType().name == "Mesh":
        let mesh = accessSingle[Mesh](header.memAddr)[]
        let verts = access[MVert](mesh.mvert).mapIt(it[])
        check verts.len == 8
        check verts[0].co == [1.0f, 1.0f, 1.0f]
        check verts[7].co == [-1.0f, -1.0f, -1.0f]
        let edges = access[MEdge](mesh.medge).mapIt(it[])
        check edges.len == 12
        check edges[0].v1 == 5
        check edges[11].v1 == 3
        let polies = access[MPoly](mesh.mpoly).mapIt(it[])
        check polies.len == 6
        check polies[0].loopstart == 0
        check polies[5].loopstart == 20
        let loops = access[MLoop](mesh.mloop).mapIt(it[])
        check loops.len == 24
        check loops[0].v == 2
        check loops[23].v == 0

        break


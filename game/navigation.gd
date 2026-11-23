extends RefCounted

const CELL = 2.0
const HALF = 104
const WIDTH = 209
var grid = AStarGrid2D.new()
var cursor = 0
var ready = false
var revision = 0

func _init():
 grid.region=Rect2i(-HALF,-HALF,WIDTH,WIDTH)
 grid.cell_size=Vector2(CELL,CELL)
 grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
 grid.update()

func cell(p: Vector3) -> Vector2i:
 return Vector2i(clampi(roundi(p.x/CELL),-HALF,HALF),clampi(roundi(p.z/CELL),-HALF,HALF))

func scan(game,amount=900):
 var exclude=[game.player.get_rid(),game.terrain_body]
 for e in game.enemies: exclude.append(e.node.get_rid())
 for npc in game.survivors: exclude.append(npc.get_rid())
 var shape=BoxShape3D.new(); shape.size=Vector3(2.6,1.5,2.6)
 var query=PhysicsShapeQueryParameters3D.new()
 query.shape=shape; query.exclude=exclude
 for i in range(amount):
  if cursor>=WIDTH*WIDTH: ready=true; return
  var id=Vector2i(cursor%WIDTH-HALF,cursor/WIDTH-HALF)
  var point=Vector3(id.x*CELL,0,id.y*CELL)
  point.y=game.height(point.x,point.z)+1.0
  query.transform=Transform3D(Basis.IDENTITY,point)
  grid.set_point_solid(id,not game.get_world_3d().direct_space_state.intersect_shape(query,1).is_empty() or point.y<1.1)
  cursor+=1

func invalidate():
 cursor=0; ready=false; revision+=1

func nearest_open(id: Vector2i) -> Vector2i:
 if not grid.is_point_solid(id): return id
 var best=id; var distance=INF
 for x in range(-4,5):
  for y in range(-4,5):
   var p=id+Vector2i(x,y)
   if not grid.is_in_boundsv(p) or grid.is_point_solid(p): continue
   var d=Vector2(x,y).length_squared()
   if d<distance: distance=d; best=p
 return best

func path(from: Vector3,to: Vector3) -> Array:
 if not ready: return []
 var start=nearest_open(cell(from)); var end=nearest_open(cell(to))
 if grid.is_point_solid(start) or grid.is_point_solid(end): return []
 var result=[]
 for id in grid.get_id_path(start,end): result.append(Vector3(id.x*CELL,0,id.y*CELL))
 return result

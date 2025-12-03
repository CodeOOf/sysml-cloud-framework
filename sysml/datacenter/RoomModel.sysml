// RoomModel.sysml
package RoomModel {

  part def Room;
  part def Rack;

  // A focused view of one room
  part Room1 : Room {
    part RackA1 : Rack;
    part RackA2 : Rack;
  }

  // Simple relationship example (for layout)
  Room1 -> RackA1 : part;
  Room1 -> RackA2 : part;
}


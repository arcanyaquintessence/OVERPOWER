extends Component
class_name C_Player

const HEADBOB_FREQUENCY = .05
const HEADBOB_STRENGTH = 2.5

var wish_dir:Vector3 = Vector3.ZERO

var headbob_time:float = 0.0
var look_sensitivity:float = .004
var min_vertical_look_direction:float = -67.0
var max_vertical_look_direction:float = 67.0
var min_zoom:float = 0.0
var max_zoom:float = 8.0

extends Resource
class_name LightsData

enum LightState {OFF, IDLE, FAIL}

# 8 lights total
const light_actions = {
	
	LightState.IDLE: [[1,5], [2,6], [3,7], [4,8]],
	#LightState.IDLE: [[1],[2],[3],[4],[5],[6],[7],[8]],

	LightState.FAIL: [[9],[9,10],[9,10,11],[9,10,11,12]]
	
}

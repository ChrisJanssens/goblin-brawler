extends MeshInstance3D
class_name BrawlerArm

enum ATTACK_TYPE {
	JAB,
	UPPERCUT,
	IDLE
}

var state: ATTACK_TYPE = ATTACK_TYPE.IDLE

signal jab(body: Node3D)

func _on_fist_body_entered(body: Node3D) -> void:
	jab.emit(body)

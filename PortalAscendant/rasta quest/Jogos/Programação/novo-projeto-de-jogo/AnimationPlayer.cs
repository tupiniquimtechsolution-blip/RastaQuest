using Godot;

public partial class Player : CharacterBody2D
{
	[Export] public float Speed = 200f;
	[Export] public float AttackRange = 50f;

	public override void _PhysicsProcess(double delta)
	{
		// Movimentação
		Vector2 velocity = Vector2.Zero;
		velocity.X = Input.GetActionStrength("ui_right") - Input.GetActionStrength("ui_left");
		velocity.Y = Input.GetActionStrength("ui_down") - Input.GetActionStrength("ui_up");
		Velocity = velocity.Normalized() * Speed;
		MoveAndSlide();

		// Ataque
		if (Input.IsActionJustPressed("ui_accept"))
		{
			Attack();
		}
	}

	private void Attack()
	{
		// Verifica inimigos próximos
		var enemies = GetTree().GetNodesInGroup("enemies");
		foreach (Node2D enemy in enemies)
		{
			if (Position.DistanceTo(enemy.Position) <= AttackRange)
			{
				// Causa dano ao inimigo
				enemy.Call("TakeDamage", 10);
			}
		}
	}
}

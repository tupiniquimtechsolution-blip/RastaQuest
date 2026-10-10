using Godot;

public partial class Enemy : CharacterBody2D
{
	[Export] public int Health = 50;

	public void TakeDamage(int damage)
	{
		Health -= damage;
		if (Health <= 0)
		{
			Die();
		}
	}

	private void Die()
	{
		QueueFree(); // Remove o inimigo da cena
	}
}

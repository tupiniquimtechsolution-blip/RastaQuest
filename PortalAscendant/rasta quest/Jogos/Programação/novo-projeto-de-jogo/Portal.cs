using Godot;

public partial class Portal : Area2D
{
	[Signal] public delegate void PortalEnteredEventHandler();

	public override void _Ready()
	{
		Connect("body_entered", new Callable(this, nameof(OnBodyEntered)));
	}

	private void OnBodyEntered(Node body)
	{
		if (body.IsInGroup("player"))
		{
			EmitSignal(nameof(PortalEntered));
		}
	}
}

using System.Collections;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    public float moveSpeed = 5f;   // Velocidade de movimentação
    public float jumpForce = 7f;   // Força do pulo
    public float dashSpeed = 15f;  // Velocidade do dash
    public float dashTime = 0.2f;  // Duração do dash
    public Transform groundCheck;  // Objeto que detecta o chão
    public LayerMask groundLayer;  // Define o que é chão
    public float groundCheckRadius = 0.1f; // Raio menor para mais precisão

    private Rigidbody2D rb;
    private bool isGrounded;
    private bool isDashing;

    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
    }

    void Update()
    {
        if (isDashing) return; // Se estiver no dash, cancela a movimentação normal

        // Detecta se o jogador está no chão
        isGrounded = Physics2D.OverlapCircle(groundCheck.position, groundCheckRadius, groundLayer);
        Debug.Log("Está no chão? " + isGrounded); // Mostra no Console se está detectando o chão

        // Movimentação horizontal
        float moveX = Input.GetAxis("Horizontal");
        rb.linearVelocity = new Vector2(moveX * moveSpeed, rb.linearVelocity.y);

        // Pulo
        if (Input.GetKeyDown(KeyCode.Space) && isGrounded)
        {
            rb.linearVelocity = new Vector2(rb.linearVelocity.x, jumpForce);
        }

        // Dash ao pressionar Shift (somente se estiver se movendo)
        if (Input.GetKeyDown(KeyCode.LeftShift) && moveX != 0)
        {
            StartCoroutine(Dash(moveX));
        }
    }

    IEnumerator Dash(float direction)
    {
        isDashing = true;
        float originalGravity = rb.gravityScale;
        rb.gravityScale = 0;
        rb.linearVelocity = new Vector2(direction * dashSpeed, 0);
        yield return new WaitForSeconds(dashTime);
        rb.gravityScale = originalGravity;
        isDashing = false;
    }
}

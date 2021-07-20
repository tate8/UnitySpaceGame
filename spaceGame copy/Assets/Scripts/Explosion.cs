using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[DisallowMultipleComponent]
public class Explosion : MonoBehaviour
{
    public GameObject explosion;
    public Rigidbody rigidBody;
    [SerializeField] Shield shield;
    [SerializeField] float laserHitModifier = 10f;
    private AudioSource projectileHit;


    // TODO make asteroid split into smaller pieces on hit
    public void IveBeenHit(Vector3 pos)
    {
        GameObject go = Instantiate(explosion, pos, Quaternion.identity, transform);
        projectileHit = go.GetComponent<AudioSource>();

        projectileHit.Play();
        Destroy(go, 6f);

        if (shield != null)
            shield.TakeDamage();
    }

    private void OnCollisionEnter(Collision collision)
    {
        // only do explosion if its not two asteroids colliding: was making game lag
        if (!rigidBody.transform.gameObject.CompareTag("Asteroid") && !collision.gameObject.CompareTag("Asteroid"))
        {
            if (collision.gameObject.CompareTag("Player"))
                Debug.Log("hit player");
                return;
            // get point of collision and make explosion there
            foreach (ContactPoint contact in collision.contacts)
            {
                IveBeenHit(contact.point);
            }
        }
    }

    public void AddForce(Vector3 hitPosition, Transform hitSource)
    {
        // add force when explosion happens
        IveBeenHit(hitPosition);
        Debug.LogWarning("Addforce: " + gameObject.name + "->" + hitSource.name);
        if (rigidBody == null)
            return;
        Vector3 direction = (hitSource.position - hitPosition).normalized;
        rigidBody.AddForceAtPosition(-direction * laserHitModifier, hitPosition, ForceMode.Impulse);
    }
}

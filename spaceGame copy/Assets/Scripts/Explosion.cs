using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[DisallowMultipleComponent]
public class Explosion : MonoBehaviour
{
    [SerializeField] GameObject explosion;
    [SerializeField] Rigidbody rigidBody;
    [SerializeField] Shield shield;
    [SerializeField] float laserHitModifier = 10f;


    // TODO make asteroid split into smaller pieces on hit
    public void IveBeenHit(Vector3 pos)
    {
        GameObject go = Instantiate(explosion, pos, Quaternion.identity, transform);
        Destroy(go, 6f);

        if (shield != null)
            shield.TakeDamage();
    }

    private void OnCollisionEnter(Collision collision)
    {
        // get point of collision and make explosion there
        foreach(ContactPoint contact in collision.contacts)
        {
            IveBeenHit(contact.point);
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
        rigidBody.AddForceAtPosition(direction * laserHitModifier, hitPosition, ForceMode.Impulse);
    }
}

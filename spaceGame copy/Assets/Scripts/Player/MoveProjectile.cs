using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveProjectile : MonoBehaviour
{
    [SerializeField] float sphereRadius = 2f;
    Vector3 myPrevPos;
    private IEnumerator coroutine;

    public float speed;
    public float fireSpeed;

    void Start()
    {
        myPrevPos = transform.position;
        coroutine = WaitAndDestroy(2.0f);
        StartCoroutine(coroutine);


    }

    void Update()
    {
        if (speed != 0)
        {
            Move();
        }
    }


    IEnumerator WaitAndDestroy(float waitTime)
    {
        yield return new WaitForSeconds(waitTime);
        Destroy(gameObject);
    }

    void Move()
    {

        myPrevPos = transform.position;

        transform.position += transform.forward * (speed * Time.deltaTime);

        RaycastHit[] hits = Physics.RaycastAll(new Ray(myPrevPos, (transform.position - myPrevPos).normalized), (transform.position - myPrevPos).magnitude);

        for (int i = 0; i < hits.Length; i++)
        {
            // do explosion
            Explosion temp = hits[i].transform.GetComponent<Explosion>();
            if (temp != null)
            {
                Debug.Log("hit: "+hits[i].transform.gameObject.tag);
                if (!hits[i].transform.gameObject.CompareTag("Player"))
                {
                    if (hits[i].transform.gameObject.CompareTag("Enemy"))
                    {
                        foreach (Transform child in hits[i].transform)
                            Destroy(child.gameObject);
                        Destroy(hits[i].transform.gameObject);
                    }
                    temp.IveBeenHit(hits[i].point);
                    Destroy(gameObject);
                }        
            }
            
            
            // remove voxels around it
            //Collider[] hitColliders = Physics.OverlapSphere(hits[i].point, sphereRadius);
            //foreach (var hitCollider in hitColliders)
            //{
            //    if (!hitCollider.CompareTag("Player"))
            //    {
            //        //Destroy(hitCollider.gameObject);
            //        hitCollider.GetComponent<Rigidbody>().AddExplosionForce(100, hitCollider.transform.position, 10, 3f);
            //    }
                
            //}
            
            //StartCoroutine(coroutine);
        }
    }
}
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveProjectile : MonoBehaviour
{
    Vector3 myPrevPos;
    private IEnumerator coroutine;
    //Rigidbody rb;
    public float speed;
    public float fireSpeed;

    void Start()
    {
        //myPrevPos = transform.position;
        coroutine = WaitAndDestroy(2.0f);
        StartCoroutine(coroutine);
        //rb = GetComponent<Rigidbody>();


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
        yield return new WaitForSeconds(waitTime); // destroy after waitTime
        Destroy(gameObject);
    }

    void Move()
    {

        myPrevPos = transform.position;
        //myPrevPos = rb.position;

        transform.position += transform.forward * (speed * Time.deltaTime);

        // make ray from new pos to old pos and check if it hits
        RaycastHit[] hits = Physics.RaycastAll(new Ray(myPrevPos, (transform.position - myPrevPos).normalized), (transform.position - myPrevPos).magnitude);

        for (int i = 0; i < hits.Length; i++)
        {
            Explosion temp = hits[i].transform.GetComponent<Explosion>();
            if (temp != null)
            {
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
        }
    }

    //private void OnCollisionEnter(Collision collision)
    //{
    //    Explosion temp = collision.transform.GetComponent<Explosion>();
    //    if (temp != null)
    //    {
    //        if (!collision.transform.gameObject.CompareTag("Player"))
    //        {
    //            if (collision.transform.gameObject.CompareTag("Enemy"))
    //            {
    //                foreach (Transform child in collision.transform)
    //                    Destroy(child.gameObject);
    //                Destroy(collision.transform.gameObject);
    //            }
    //            temp.IveBeenHit(collision.transform.position);
    //            Destroy(gameObject);
    //        }
    //    }
    //}
}
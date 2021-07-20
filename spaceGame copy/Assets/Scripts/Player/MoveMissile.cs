using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveMissile : MonoBehaviour
{
    Vector3 myPrevPos;
    private IEnumerator coroutine;
    public GameObject target;

    [SerializeField] float rotationalDamping = 5f;
    public float speed;
    public float fireSpeed;

    void Start()
    {
        myPrevPos = transform.position;
        coroutine = WaitAndDestroy(10.0f);
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
        // destroy after waittime
        yield return new WaitForSeconds(waitTime);
        Destroy(gameObject);
    }

    void Move()
    {

        myPrevPos = transform.position;

        ChangePos();
        Turn();

        // send ray from new pos to old pos and check if it hits
        RaycastHit[] hits = Physics.RaycastAll(new Ray(myPrevPos, (transform.position - myPrevPos).normalized), (transform.position - myPrevPos).magnitude);

        for (int i = 0; i < hits.Length; i++)
        {
            Debug.DrawLine(transform.position, hits[i].transform.position, Color.green);

            // do explosion
            //Explosion temp = hits[i].transform.GetComponent<Explosion>();
            //if (temp != null)
            //{
                // if it's not player
                if (!hits[i].transform.gameObject.CompareTag("Player"))
                {
                    // if it's an enemy
                    if (hits[i].transform.gameObject.CompareTag("Enemy"))
                    {
                        // destroy enemy if hit
                        foreach (Transform child in hits[i].transform)
                            Destroy(child.gameObject);
                        Destroy(hits[i].transform.gameObject);
                    }
                    //temp.IveBeenHit(hits[i].point);
                    Destroy(gameObject);
                //}
            }
        }
    }
    void ChangePos()
    {
        // move toward target
        if(gameObject != null)
            transform.position += transform.forward * speed * Time.deltaTime;
    }

    void Turn()
    {
        // turn toward the target
        if (gameObject != null && target != null)
        {
            Vector3 pos = target.transform.position - transform.position;
            Quaternion rotation = Quaternion.LookRotation(pos);
            transform.rotation = Quaternion.Slerp(transform.rotation, rotation, rotationalDamping * Time.deltaTime);
        }
        else
            Destroy(gameObject);
    }
}
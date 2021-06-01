using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LockOn : MonoBehaviour
{
    // NOT IN USE

    [SerializeField] Image targetImage;
    [SerializeField] float timedTarget = 1.0f;
    [SerializeField] bool lockOn;
    [SerializeField] float lockTarget;
    [SerializeField] int rayLength = 200;
    [SerializeField] GameObject homingMissile;
    //private HomingMissile missileScript;
    [SerializeField] GameObject enemyTarget;
    [SerializeField] AudioSource lockSound;
    [SerializeField] AudioSource trackingSound;
    [SerializeField] Animator anim;

    private void Start()
    {
        //missileScript = homingMissile.GetComponent<HomingMissile>();
        //missileScript.enabled = false;
        anim = GameObject.Find("Reticle").GetComponentInChildren<Animator>();
    }

    private void Update()
    {
        LockedOn();
    }

    void LockedOn()
    {
        Vector3 fwd = transform.TransformDirection(Vector3.forward);
        RaycastHit hit;

        if(Physics.Raycast(transform.position, fwd, out hit, rayLength))
        {
            enemyTarget = hit.collider.gameObject;

            if (!lockOn)
            {
                lockOn = true;
                lockTarget = Time.time + timedTarget;
                Debug.Log("tracking");
                trackingSound.enabled = true;
                anim.SetBool("track", true);
                anim.SetBool("redLock", true);
            }
        }
        else
        {
            lockOn = false;
            //missileScript.enabled = false;
            lockSound.enabled = false;
            trackingSound.enabled = false;
            anim.SetBool("track", false);
            anim.SetBool("redLock", false);
        }
    }
} 

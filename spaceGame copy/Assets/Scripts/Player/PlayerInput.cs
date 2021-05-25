using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerInput : MonoBehaviour
{
    [SerializeField] Laser[] laser;

    private void Start()
    {
        //Cursor.visible = false;
    }

    void Update()
    {
        // player shooting
        //if (Input.GetMouseButtonDown(0))
        //{
        //    foreach(Laser l in laser)
        //    {
        //        //Vector3 pos = transform.position + (transform.forward * l.Distance);
        //        l.FireLaser();
        //    }
        //}
    }
}

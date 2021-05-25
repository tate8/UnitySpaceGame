using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyRotateToPlayer : MonoBehaviour
{
    [SerializeField] GameObject player;

    public Camera cam;
    public float maximumLength;

    private Vector3 pos;
    private Vector3 direction;
    private Quaternion rotation;

    void Update()
    {
        RaycastHit hit;
        var pos = player.transform;
        Vector3 fwd = transform.TransformDirection(Vector3.forward);
        if (Physics.SphereCast(transform.position,5, fwd, out hit, 1000))
        {
            RotateToPlayerDirection(gameObject, hit.point);
        }
    }

    void RotateToPlayerDirection(GameObject obj, Vector3 destination)
    {
        direction = destination - obj.transform.position;
        rotation = Quaternion.LookRotation(direction);
        obj.transform.localRotation = Quaternion.Lerp(obj.transform.rotation, rotation, 1);
        Debug.DrawRay(obj.transform.position, direction, Color.green);

    }
    public Quaternion GetRotation()
    {
        return rotation;
    }
}



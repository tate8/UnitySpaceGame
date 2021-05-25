using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Asteroid : MonoBehaviour
{
    [SerializeField] float minScale = 1.6f;
    [SerializeField] float maxScale = 2.4f;
    [SerializeField] float rotationOffset = 50f;


    Transform myT;
    Vector3 randomRotation;
    private void Awake()
    {
        myT = transform;
    }

    void Start()
    {
        ChangeScale();
        RandomRotation();
    }

    void Update()
    {
        myT.Rotate(randomRotation * Time.deltaTime);
        
    }

    private void ChangeScale()
    {
        Vector3 scale = Vector3.one;
        scale.x = Random.Range(minScale, maxScale);
        scale.y = Random.Range(minScale, maxScale);
        scale.z = Random.Range(minScale, maxScale);
        myT.localScale = scale;
    }

    private void RandomRotation()
    {
        randomRotation.x = Random.Range(-rotationOffset, rotationOffset);
        randomRotation.y = Random.Range(-rotationOffset, rotationOffset);
        randomRotation.z = Random.Range(-rotationOffset, rotationOffset);
    }



}

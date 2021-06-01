using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeCamera : MonoBehaviour
{
    [SerializeField] GameObject ThirdPersonCam;
    [SerializeField] GameObject FirstPersonCam;
    [SerializeField] int CamMode;

    private void Update()
    {
        // press C to switch from 3rd to 1st person
        if (Input.GetKeyDown(KeyCode.C))
        {
            if (CamMode == 1)
            {
                CamMode = 0;
            }
            else
            {
                CamMode += 1;
            }
            StartCoroutine(CamChange());
        }
    }

    IEnumerator CamChange()
    {
        yield return new WaitForSeconds(0.01f);
        if (CamMode == 0)
        {
            ThirdPersonCam.SetActive(true);
            FirstPersonCam.SetActive(false);
        }
        if (CamMode == 1)
        {
            ThirdPersonCam.SetActive(false);
            FirstPersonCam.SetActive(true);
        }
    }
}

using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class SwitchLockOnZone : MonoBehaviour
{

    [SerializeField] GameObject image; // Drag & Drop the image in the inspector


    public void SetActive(bool tf)
    {
        if (tf == true)
            image.SetActive(true);
        else
            image.SetActive(false);

    }

    public void TurnRed()
    {
        // change lock UI to red
        image.GetComponent<Image>().color = new Color32(255, 100, 100, 255);

    }

    public void TurnWhite()
    {
        // change lock UI to white
        image.GetComponent<Image>().color = new Color32(225, 225, 225, 255);
    }
}
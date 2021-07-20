using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundManager : MonoBehaviour
{
    public AudioSource thrusterSound;
    public AudioSource gunSound;
    public AudioSource laserSound;


    private void Start()
    {
        thrusterSound.Stop();
        gunSound.Stop();
        laserSound.Stop();
    }


    public void PlayThrustSound()
    {
        if(!thrusterSound.isPlaying)
        {
            thrusterSound.Play();
        }
    }

    public void StopThrustSound()
    {
        thrusterSound.Stop();
    }

    public void PlayGunSound()
    {
        if (!gunSound.isPlaying)
        {
            gunSound.Play();
        }
    }

    public void StopGunSound()
    {
        gunSound.Stop();
    }

    public void PlayLaserSound()
    {
        if (!laserSound.isPlaying)
        {
            laserSound.Play();
        }
    }

    public void StopLaserSound()
    {
        laserSound.Stop();
    }
}

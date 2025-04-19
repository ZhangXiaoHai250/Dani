using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Control : MonoBehaviour
{
    public GameObject loadGameUI;
    Animator loadGameAnimator;
    GameObject uiCanvas;
    private void Awake()
    {
        loadGameAnimator = loadGameUI.GetComponent<Animator>();
    }
    private void Start()
    {
        StartCoroutine(LoadUI("LoadGameUiAnimationEnd"));
    }
    IEnumerator LoadGame(GameObject game)
    {
        Instantiate(game);
        yield return null;
    }
    public void PlayerGame()
    {
        StartCoroutine(LoadUI("LoadGameUiAnimationStart"));
    }
    IEnumerator LoadUI(string animationName)
    {
        loadGameAnimator.Play(animationName);
        
        yield return null;
    }
    public void LoadGame(int i)
    {
        StartCoroutine(IELoadGame(i));
    }
    IEnumerator IELoadGame(int i)
    {
        AsyncOperation asyncLoad = SceneManager.LoadSceneAsync(i);
        asyncLoad.allowSceneActivation = false; // 禁止自动激活场景

        float time = 0;//判断动画是否播放完毕
        AnimatorStateInfo stateInfo = loadGameAnimator.GetCurrentAnimatorStateInfo(0);
        float animationLength = stateInfo.length;
        while (!asyncLoad.isDone)
        {
            float progress = asyncLoad.progress;
            time += Time.deltaTime;
            if (progress >= 0.9f && time >= animationLength)
            {
                StartCoroutine(LoadUI("LoadGameUiAnimationEnd"));
                asyncLoad.allowSceneActivation = true; // 手动激活场景
                Debug.Log("切换到场景：" + i);
            }
            yield return null;
        }
    }

}

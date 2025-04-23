using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

[ExecuteAlways] // 允许在编辑器模式下预览效果
public class Control : MonoBehaviour
{
    [Header("加载面板UI，将设置好的加载UI附着在此\\n确保UI在最底层\\n加载动画名称规范：\\n开始“LoadGameUiAnimationStart”\\n结束“LoadGameUiAnimationEnd”\\n设置好后在按钮调用PlayerGame()和LoadGame(场景索引)")]
    public GameObject loadGameUI;
    Animator loadGameAnimator;
    private void Awake()
    {
        try
        {
            loadGameAnimator = loadGameUI.GetComponent<Animator>();
        }
        catch
        {
            Debug.LogError("请添加动画器");
        }
        
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
        try
        {
            loadGameAnimator.Play(animationName);
        }
        catch
        {
            Debug.LogError("请添加动画器,或者确保结束动画名称为：LoadGameUiAnimationStart 加载名称为：LoadGameUiAnimationStart");
        }


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

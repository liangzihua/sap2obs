# sap2obs
SAP和华为OBS交互
# SAP与OBS通讯接口架构及技术说明

---

作者： 梁子华   日期：2021-03-22    

---

> **版本信息**
>
> | 版本 | 日期       | 作者   | 描述                   |
> | ---- | :--------- | ------ | ---------------------- |
> | V1.0 | 2021-03-22 | 梁子华 | 初始版本               |
> | V2.0 | 2021-04-10 | 梁子华 | 增加文件显示和复制功能 |
> | V3.0 | 2022-11-05 | 梁子华 | 增加列举桶内对象功能   |

## 目录

[toc]

## 1. 业务背景

> 业务需求用文件传输来实现接口，或者需要将附件保存到服务器（照片、合同附件等等）。


常规的做法有两种:

- 一种是搭建FTP/SFTP服务器。 
  SAP封装了FTP函数来操作文件。 常用的FTP函数如下，

  FTP_CONNECT	连接FTP		

  FTP_DISCONNECT 断开连接

  FTP_COMMAND     发送FTP命令

  FTP_COMMAND_LIST 发送多个FTP命令

  FTP_R3_TO_SERVER 将文件放到FTP

  FTP_SERVER_TO_R3 从FTP读取文件

  

  但对于SFTP，需要安全认证，目前ABAP不能直接访问SFTP，需借用PI或JAVA来实现。

- 第二种是搭建文档服务器或存储服务器。使用HTTP RESTful访问（PUT、GET、DELETE等等）。 一般在访问前可以通过获取Token或签名的方式，来保证文件的安全访问。

本文介绍的华为云OBS（以下简称OBS），是华为云的对象存储服务。

## 2. 接口架构

对开发者来说，OBS提供了API和SDK的方式访问。由于ABAP代码不能引入JAR包，所以只能用API的方式。 

OBS的访问需要先根据AK（访问密钥）和SK（私有访问密钥）计算签名，然后将签名放到HTTP请求中。 

由于ABAP不能实现这个签名算法，所以我们需要一个能执行这段JAVA代码的环境来计算签名（当然，如果后续SAP支持这段算法计算的，也可以直接在SAP计算签名）。

假设有一个外围的JAVA系统能开启一个服务计算签名，这个问题就解决了。但目前没有这样的外围系统，所以我们借用PI的User-Defined Function（UDF)来说实现这段签名算法。 

借用PI的UDF需要配置PI接口，但我们不需要跟外围系统进行交互， 所以PI的发送方和接受方都是SAP系统。

![image-20221105140941421.png](https://github.com/liangzihua/sap2obs/blob/main/image/image-20221105140941421.png)

## 3. 接口实现

### 3.1 计算签名

#### 3.1.1 签名算法的实现	

##### 3.1.1.1 OBS 授权方式

​		OBS授权方式主要有4种，详细可参考华为云官方文档。**[https://support.huaweicloud.com/api-obs/obs_04_0008.html](https://support.huaweicloud.com/api-obs/obs_04_0008.html)**

- **[1. 用户签名验证](https://support.huaweicloud.com/api-obs/obs_04_0009.html)**
- **[2. Header中携带签名](https://support.huaweicloud.com/api-obs/obs_04_0010.html)**
- **[3. URL中携带签名](https://support.huaweicloud.com/api-obs/obs_04_0011.html)**
- **[4. 基于浏览器上传的表单中携带签名](https://support.huaweicloud.com/api-obs/obs_04_0012.html)**

本次接口使用第2种和第3种。

##### 3.1.1.2 Header和URL中携带签名的区别

  * 签名算法不一样

    * URL中携带签名

      需要传入有效期（单位秒），当前系统时间的秒数+传入的有效期作为计算签名的参数

      ```java
      StringToSign = 
           HTTP-Verb + "\n" +   
           Content-MD5 + "\n" +   
           Content-Type + "\n" +   
           Expires + "\n" +   
           CanonicalizedHeaders +   CanonicalizedResource; 
      ```

      

    * Header中携带签名

      取当前系统时间转换成GMT格式作为计算签名的参数

      ```java
      StringToSign = 
          HTTP-Verb + "\n" + 
          Content-MD5 + "\n" + 
          Content-Type + "\n" + 
          Date + "\n" + 
          CanonicalizedHeaders + CanonicalizedResource
      ```

      

  * 创建HTTP请求时，授权信息放的位置不一样

    * URL中携带签名，授权信息作为URL的参数：

      HOST/ObjectKey?AccessKeyId=AccessKeyID&Expires=ExpiresValue&Signature=signature

    * Header中携带签名

      * URL中不带授权信息（HOST/ObjectKey）；
      * 授权信息放到Header中。

##### 3.1.1.3 对象

> OBS没有文件夹的概念。为了使用户更方便进行管理数据，OBS提供了一种方式模拟文件夹：通过在对象的名称中增加“/”，例如“test/123.jpg”。此时，“test”就被模拟成了一个文件夹，“123.jpg”则模拟成“test”文件夹下的文件名了，而实际上，对象名称（Key）仍然是“test/123.jpg”。此类命名方式的对象，在控制台上会以文件夹的形式展示。
>
> 单次上传对象大小范围是[0, 5GB]，如果需要上传超过5GB的大文件，需要通过[多段操作](https://support.huaweicloud.com/api-obs/obs_04_0096.html)来分段上传(目前SAP未开发此功能)。

* 对象Key包含**空格和中文**,直接作为ObjectKey计算签名是无效的，所以对象Key需要进行**URL转义**；

* SAP **URL转义**(URL Escaping)实现方式，调用CL_HTTP_UTILITY=>ESCAPE_URL将对象Key进行编码转义。

  

##### 3.1.1.4 签名算法实现

​		签名的计算过程如下：

​		1、构造请求字符串(StringToSign)。

​		2、对第一步的结果进行UTF-8编码。

​		3、使用SK对第二步的结果进行HMAC-SHA1签名计算。

​		4、对第三步的结果进行Base64编码。

​		5、对第四步的结果进行URL编码，得到签名。

签名算法

```java
import org.json.JSONObject;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;

public class OBSCopyObject {

    public static void main(String[] args) {

        System.out.println("" + CalcObsSigntrue("PUT",
                "",
                "",
                "Header",
                3600,
                "",
                "",
                "",//x-obs-copy-source:/sap-mm-attachment/S4D/1111.xlsx
                ""));//
    }


    /**
     * @param httpMethod http请求操作方法,PUT/GET/DELETE
     * @param accessKey 访问密钥AK
     * @param securityKey 私有访问密钥SK
     * @param authorType 签名授权方式(Header中携带签名、URL中携带签名)
     * @param expires 有效期Header中携带签名、URL中携带签名
     * @param contentType Content-Type
     * @param contentMD5 Content-MD5
     * @param canonicalizeHeaders HTTP请求头域中的OBS请求头字段
     * @param canonicalizeResource HTTP请求所指定的OBS资源
     * @return JSON字符串
     * @author 梁子华
     * @describe: 计算签名
     * @date 2021-03-30
     */
    public static String CalcObsSigntrue(String httpMethod, //http请求操作方法
                                         String accessKey, //访问密钥AK
                                         String securityKey, //私有访问密钥SK
                                         String authorType, //签名授权方式
                                         int expires,//有效期
                                         String contentType,// Content-Type内容类型
                                         String contentMD5, // Content-MD5
                                         String canonicalizeHeaders,//HTTP请求头域中的OBS请求头字段
                                         String canonicalizeResource //HTTP请求所指定的OBS资源
    ) {
        String resultJson = ""; //结果JSON字符串
        String canonicalString = "";//计算签名的字符串
        String requestTime = ""; //请求时间
        long longExpires = 0; // 有效期

        long time = System.currentTimeMillis();//当前时间
        //有效期
        if (expires == 0) {
            expires = 3600;
        }
        longExpires = (time / 1000) + expires;
        //请求时间
        DateFormat serverDateFormat = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.ENGLISH);
        serverDateFormat.setTimeZone(TimeZone.getTimeZone("GMT"));
        requestTime = serverDateFormat.format(time);

        // Content-MD5 、Content-Type 没有直接换行， data格式为RFC 1123，和请求中的时间一致
        if (authorType.toUpperCase().equals("URL")) {
            //URL中携带签名
            canonicalString = httpMethod + "\n"
                    + contentMD5 + "\n"
                    + contentType + "\n"
                    + longExpires + "\n"
                    + canonicalizeHeaders
                    + canonicalizeResource;
        } else {
            //Header中携带签名
            canonicalString = httpMethod + "\n"
                    + contentMD5 + "\n"
                    + contentType + "\n"
                    + requestTime + "\n"
                    + canonicalizeHeaders
                    + canonicalizeResource;
        }

        String signature = "";
        try {
            SecretKeySpec signingKey = new SecretKeySpec(securityKey.getBytes(StandardCharsets.UTF_8), "HmacSHA1");
            Mac mac = Mac.getInstance("HmacSHA1");
            mac.init(signingKey);
            signature = Base64.getEncoder().encodeToString(mac.doFinal(canonicalString.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (InvalidKeyException e) {
            e.printStackTrace();
        }

        /**处理返回结果**/
        Map<String, String> map = new HashMap<String, String>();

        //授权方式 URL/HEADER
        map.put("authorType", authorType.toUpperCase());
        //指接口操作的方法，对REST接口而言，即为http请求操作的VERB，如："PUT"，"GET"，"DELETE"等字符串。
        map.put("HttpMethod", httpMethod.toUpperCase());
        //AK
        map.put("AccessKeyId", accessKey);
        //SK
        map.put("securityKey", securityKey);
        //签名
        map.put("signature", signature);
        //Authorization
        String authorization = "OBS " + accessKey + ":" + signature;
        map.put("Authorization", authorization);
        //Expires
        map.put("Expires", String.valueOf(longExpires));
        //Date 生成请求的时间，该时间格式遵循RFC 1123；该时间与当前服务器的时间超过15分钟时服务端返回403。
        map.put("Date", requestTime);
        //Content-Type 内容类型，用于指定消息类型，例如： text/plain。
        map.put("contentType", contentType);
        //Content-MD5 按照RFC 1864标准计算出消息体的MD5摘要字符串，即消息体128-bit MD5值经过base64编码后得到的字符串，可以为空。
        map.put("contentMD5", contentMD5);
        //HTTP请求头域中的OBS请求头字段，即以“x-obs-”作为前辍的头域，如“x-obs-date，x-obs-acl，x-obs-meta-*”。
        map.put("canonicalizeHeaders", canonicalizeHeaders);
        // 表示HTTP请求所指定的OBS资源，构造方式如下：
        //<桶名+对象名>+[子资源1] + [子资源2] + ...
        map.put("canonicalizeResource", canonicalizeResource);

        //数组转换JSON，JSON转换为String
        JSONObject jsonObject = new JSONObject(map);
        resultJson = jsonObject.toString();

        return resultJson;

    }

}

```



#### 3.1.2 PI接口 

##### 3.1.2.1 创建PI接口和User-Defined Function

​		在PI创建一个同步的接口，接口的发送方和接收方系统都是S4。在接口中的Message Mapping中，创建自定义函数User-Defined Function，将JAVA代码中CalcObsSigntrue方法复制到User-Defined Function.

User-Defined Function

![image-20221105112803336](https://github.com/liangzihua/sap2obs/blob/main/image/image-20221105112803336.png)

在消息类型映射Message Mapping中引用自定义的User-Defined Function

![image-20221105112622118](https://github.com/liangzihua/sap2obs/blob/main/image//image-20221105112622118.png)

##### 3.1.2.2 PI代码实现

  * 创建一个公共类ZCL_OBS，包含SAP与OBS接口通讯的所有操作
  * 在S4创建自定义签名信息表ZOBST_SIGNTRUE,存储PI返回的签名信息
  * 实现PI接口代理类：
      在类ZCL_OBS中创建获取签名的方法GET_SIGNTRUE，
       * 先调用PI Outbound的接口，将计算签名所需的信息发送到PI。
     * 在PI Inbound接口中，将返回的签名信息存到表ZOBS_SIGNTRUE；
     * 在方法GET_SIGNTRUE中取出返回的签名信息。

```ABAP
   METHOD get_signtrue.
    DATA: lo_proxy_out    TYPE REF TO zpico_si_bc000501_erp2erp_syn,
          ls_output       TYPE zpimt_bc000501_req_out,
          ls_input        TYPE zpimt_bc000501_res,
          ls_bc000501_req TYPE zpidt_bc000501_req,
          lv_message      TYPE bapi_msg,
          lv_uuid         TYPE sysuuid_c32,
          lv_seconds      TYPE p LENGTH 3 DECIMALS 1 VALUE '0.1'.
    CLEAR: ls_output,
           ls_input,
           es_return,
           rs_signtrue,
           lv_uuid.
    " 1. 根据桶的配置获取AK/SK
    CLEAR: ms_obs_config.
    CALL METHOD get_obs_config
      EXPORTING
        iv_bucketname = is_signtrue_req-bucketname
*       iv_httpmethod = is_signtrue_req-httpmethod
      IMPORTING
        es_obs_config = ms_obs_config.
    IF ms_obs_config IS INITIAL.
      "桶&1方法&2的签名配置丢失或未激活，请检查表ZOBS_CONFIG
      MESSAGE e003 WITH is_signtrue_req-bucketname is_signtrue_req-httpmethod INTO lv_message.
      es_return = zcl_message=>convert_syst_to_bapiret2( ).
      RETURN.
    ELSE.
      "insert begin by kevin.liang on 20210401
      "AK/SK包含空格会导致计算签名出错
      CONDENSE: ms_obs_config-obsak ,
                ms_obs_config-obssk .
      "insert end by kevin.liang on 20210401
    ENDIF.

    "2. 调用PI计算签名
    CLEAR: ls_bc000501_req.
    "获取UUID
    TRY .
        CALL METHOD cl_system_uuid=>if_system_uuid_static~create_uuid_c32
          RECEIVING
            uuid = lv_uuid.
      CATCH cx_uuid_error.

    ENDTRY.
    ls_bc000501_req-uuid                     = lv_uuid                             ."请求PI的唯一码
    ls_bc000501_req-http_method              = mv_http_method          ."http请求操作方法,PUT/GET/DELETE
    ls_bc000501_req-access_key               = ms_obs_config-obsak                 ."访问密钥AK
    ls_bc000501_req-security_key             = ms_obs_config-obssk                 ."私有访问密钥SK
    ls_bc000501_req-author_type              = is_signtrue_req-authortype          ."签名授权方式(Header中携带签名、URL中携带签名)
    ls_bc000501_req-expires                  = is_signtrue_req-expires             ."有效期
    ls_bc000501_req-content_type             = is_signtrue_req-contenttype         ."Content-Type内容类型
    ls_bc000501_req-content_md5              = is_signtrue_req-contentmd5          ."Content-MD5
    ls_bc000501_req-canonicalize_headers     = is_signtrue_req-canonicalizeheaders ."HTTP请求头域中的OBS请求头字段
    ls_bc000501_req-canonicalize_resource    = is_signtrue_req-canonicalizeresource."HTTP请求所指定的OBS资源

    "调用PI计算签名
    CALL METHOD calc_signtrue
      EXPORTING
        is_bc000501_req = ls_bc000501_req
      IMPORTING
        es_return       = es_return
      RECEIVING
        rs_signtrue     = rs_signtrue.

    ms_signtrue =  rs_signtrue.

  ENDMETHOD.
```



### 3.2 文件操作

​		创建配置表ZOBS_CONFIG, 用来配置每个桶不同请求方法的AK、SK以及日志保留天数等等。

​		在类ZCL_OBS中创建6基本操作方式,授权方式默认使用header中携带签名;

1. [附件上载UPLOAD_ATTACHMENT](#3.2.1 附件上载 UPLOAD_ATTACHMENT)>;

2. [附件下载DOWNLOAD_ATTACHMENT](#3.2.2 附件下载 DOWNLOAD_ATTACHMENT) ;

3. [附件删除DELETE_ATTACHMENT](#3.2.3 附件删除 DELETE_ATTACHMENT)；

4. 另外创建直接[下载文件内容的方法DOWNLOAD_FILE](#3.2.4 文件内容下载 DOWNLOAD_FILE)，采用**[URL携带签名的方式授权](#3.1.1.1 OBS 授权方式)**；

5. [显示附件 DISPLAY_ATTACHMENT](#3.2.5 显示附件 DISPLAY_ATTACHMENT)

6. [复制附件](#3.2.6 复制附件)

   

#### 3.2.1 附件上载 UPLOAD_ATTACHMENT

   -  附件上载使用PUT方法;

   - 调用计算签名方法；

   - 创建HTTP客户端，HOST需要包含Object Key；

   - 设置HTTP头域（Header）；

   - 将本地文件转换成XSTRING，并填充到HTTP Client；

   - 发送请求，并提取返回的结果。

     ```ABAP
       METHOD upload_attachment.
         CALL METHOD upload_object
           EXPORTING
             iv_bucketname = iv_bucketname
             iv_filename   = iv_filename
             iv_data       = iv_data
             iv_objectkey  = iv_objectkey
           IMPORTING
             es_return     = es_return
             es_result     = es_result.
     
         "记录日志
         logging_obslog( is_return = es_return is_result = es_result ).
     
         "日志自动清理
         clear_obslog( ).
     
       ENDMETHOD.
     
     ```

     ```ABAP
       
       METHOD upload_object.
     
         DATA: lv_objectkey TYPE string.
     
         DATA: lv_data       TYPE xstring,
               lv_filelength TYPE i,
               lv_message    TYPE bapi_msg.
     
     
         "设置桶信息
         set_bucket( iv_bucketname = iv_bucketname iv_objectkey = iv_objectkey ).
         "设置OBS操作
         set_action( c_action_upload ).
     
         CLEAR: lv_objectkey.
         lv_objectkey = iv_objectkey.
     
         CALL METHOD adjust_objectkey
           IMPORTING
             es_return    = es_return
           CHANGING
             cv_objectkey = lv_objectkey.
         IF es_return-type NA 'EAX'.
     
           "获取OBS的签名
           CLEAR:ms_signtrue_req         ,
                 es_return               ,
                 es_result               .
           ms_signtrue_req-bucketname             = iv_bucketname.
           ms_signtrue_req-httpmethod             = mv_http_method.
           ms_signtrue_req-authortype             = c_authortype_header.
           ms_signtrue_req-contenttype            = c_contenttype_bin .
           ms_signtrue_req-contentmd5             = ''.
           ms_signtrue_req-canonicalizeheaders    = ''.
           ms_signtrue_req-canonicalizeresource   = '/' && iv_bucketname && lv_objectkey.
     
           CALL METHOD get_signtrue
             EXPORTING
               is_signtrue_req = ms_signtrue_req
             IMPORTING
               es_return       = es_return.
     
         ENDIF.
     
         IF es_return-type NA 'EAX'.
           "上载文件
           IF iv_filename IS NOT INITIAL.
             CALL METHOD gui_upload
               EXPORTING
                 iv_filename   = iv_filename
               IMPORTING
                 ev_filelength = lv_filelength
               RECEIVING
                 rv_data       = lv_data
               EXCEPTIONS
                 error         = 1
                 OTHERS        = 2.
             IF sy-subrc <> 0.
               es_return = zcl_message=>convert_syst_to_bapiret2( ).
             ENDIF.
           ELSEIF iv_data IS NOT INITIAL.
             lv_data       = iv_data.
             lv_filelength = xstrlen( lv_data ).
           ELSE.
             "上载内容不能为空
             MESSAGE e015 INTO lv_message.
             es_return = zcl_message=>convert_syst_to_bapiret2( ).
     
           ENDIF.
     
           IF es_return-type NA 'EAX'.
     
             "采用HTTP Client访问OBS
             call_obs_httpclient( EXPORTING iv_objectkey = lv_objectkey
                                            iv_data      = lv_data       "二进制数据
                                            iv_length    = lv_filelength
                                  IMPORTING es_return    = es_return
                                            es_result    = es_result     ).
     
             IF es_result-code = 200.
               "附件上载成功，ObjectKey为&1.
               MESSAGE s005 WITH iv_objectkey INTO lv_message.
               es_return = zcl_message=>convert_syst_to_bapiret2( ).
             ELSE.
               "附件上载失败，错误原因：&1&2
               MESSAGE e006 WITH es_result-code  es_result-reason INTO lv_message.
               es_return = zcl_message=>convert_syst_to_bapiret2( ).
             ENDIF.
     
           ENDIF.
     
         ENDIF.
     
       ENDMETHOD.
     ```

     

* 测试程序ZOBS_DEMO_ATTCH_UPLOAD

  ```ABAP
  *&---------------------------------------------------------------------*
  *& Report ZOBS_ATTCH_UPLOAD_TEST
  *&---------------------------------------------------------------------*
  *&
  *&---------------------------------------------------------------------*
  REPORT zobs_demo_attch_upload.
  
  
  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
    PARAMETERS: p_bucket TYPE zzbucket_obs.
    PARAMETERS: p_file TYPE rlgrap-filename MEMORY ID zfilename.
  
  SELECTION-SCREEN END OF BLOCK b1.
  
  
  AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
    PERFORM frm_select_file CHANGING p_file.
  
  START-OF-SELECTION.
    "上载文件
    PERFORM frm_upload_file.
  
  *&---------------------------------------------------------------------*
  *& Form frm_upload_file
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_upload_file .
    DATA: lo_obs       TYPE REF TO  zcl_obs,
          lv_filename  TYPE string,
          lv_objectkey TYPE string.
  
    lv_filename = p_file.
    
    CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
      EXPORTING
        full_name     = lv_filename
      IMPORTING
        stripped_name = lv_objectkey
  *     FILE_PATH     =
      EXCEPTIONS
        x_error       = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
  * Implement suitable error handling here
    ENDIF.
  
    lv_objectkey = '/sapdemo/' && sy-datum && '/' && lv_objectkey.
  
    CREATE OBJECT lo_obs.
  
    CALL METHOD lo_obs->upload_attachment
      EXPORTING
        iv_bucketname = p_bucket
        iv_filename   = lv_filename
        iv_objectkey  = lv_objectkey
  *     iv_expires    = 3600
      IMPORTING
        es_return     = DATA(ls_return).
  
      IF ls_return IS NOT INITIAL..
        MESSAGE ID ls_return-id
              TYPE ls_return-type
            NUMBER ls_return-number
              WITH ls_return-message_v1
                   ls_return-message_v2
                   ls_return-message_v3
                   ls_return-message_v4.
  
      ENDIF.
  
  ENDFORM.
  
  *&---------------------------------------------------------------------*
  *& Form frm_select_file
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_select_file CHANGING cv_file TYPE rlgrap-filename .
    DATA: lt_filetable TYPE filetable,
          ls_filetable TYPE file_table,
          lv_subrc     TYPE i,
          lv_title     TYPE string..
  
  
    lv_title = TEXT-t01.
  
    CALL METHOD cl_gui_frontend_services=>file_open_dialog
      EXPORTING
        window_title            = lv_title
  *      file_filter             = 'Excel(*.xlsx)|*.xlsx|Excel(*.xls)|*.xls'
      CHANGING
        file_table              = lt_filetable
        rc                      = lv_subrc
      EXCEPTIONS
        file_open_dialog_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        not_supported_by_gui    = 4
        OTHERS                  = 5.
    IF sy-subrc EQ 0.
      LOOP AT lt_filetable INTO ls_filetable.
        cv_file = ls_filetable-filename.
      ENDLOOP.
    ENDIF.
  
  ENDFORM.
  ```

  

#### 3.2.2 附件下载 DOWNLOAD_ATTACHMENT 

> 附件下载，FTYPE参数默认是BIN，返回二进制格式;如果需要[直接返回文本内容](#3.2.4 文件内容下载 DOWNLOAD_FILE)，则赋值为TEXT

   -  附件上载使用GET方法;

   - 调用计算签名方法；

   - 创建HTTP客户端，HOST需要包含Object Key；

   - 设置HTTP头域（Header）；

   - 发送请求；

   - 获取返回的结果，并将返回的数据XSTRING下载到本地。

     ```ABAP
        METHOD download_attachment.
     
         CALL METHOD download_object
           EXPORTING
             iv_bucketname       = iv_bucketname
             iv_objectkey        = iv_objectkey
             iv_filetype         = iv_filetype
             iv_direct_down      = iv_direct_down
             iv_newline          = iv_newline
             iv_default_filename = iv_default_filename
           IMPORTING
             es_return           = es_return
             es_result           = es_result.
     
         "记录日志
         logging_obslog( is_return = es_return is_result = es_result ).
         "日志自动清理
         clear_obslog( ).
     
     
       ENDMETHOD.
     ```

     ```ABAP
       METHOD download_object.
     
         DATA: lv_message    TYPE bapi_msg.
     
         DATA: lv_filename    TYPE string,
               lv_extension   TYPE string,
               lv_objectkey   TYPE string,
               lv_user_action TYPE i,
               lv_action      TYPE zzaction_obs.
         DATA:lt_extension TYPE TABLE OF string,
              lv_lines     TYPE i.
     
     
         "设置桶信息
         set_bucket( iv_bucketname = iv_bucketname iv_objectkey = iv_objectkey ).
         "设置OBS操作
         set_action( c_action_download ).
     
         CLEAR: lv_objectkey.
         lv_objectkey = iv_objectkey.
     
         CALL METHOD adjust_objectkey
           IMPORTING
             es_return    = es_return
           CHANGING
             cv_objectkey = lv_objectkey.
         IF es_return-type CA 'EAX'.
           RETURN.
         ENDIF.
     
         "获取OBS的签名
         CLEAR:ms_signtrue_req         ,
               es_return               ,
               es_result               .
         ms_signtrue_req-bucketname             = iv_bucketname.
         ms_signtrue_req-httpmethod             = mv_http_method.
         ms_signtrue_req-authortype             = c_authortype_header.
         ms_signtrue_req-contenttype            = c_contenttype_bin .
         ms_signtrue_req-contentmd5             = ''.
         ms_signtrue_req-canonicalizeheaders    = ''.
         ms_signtrue_req-canonicalizeresource   = '/' && iv_bucketname && lv_objectkey.
     
         CALL METHOD get_signtrue
           EXPORTING
             is_signtrue_req = ms_signtrue_req
           IMPORTING
             es_return       = es_return.
     
         IF es_return-type CA 'EAX'.
           RETURN.
         ENDIF.
     
         "采用HTTP Client访问OBS
         call_obs_httpclient( EXPORTING iv_objectkey = lv_objectkey
                              IMPORTING es_return    = es_return
                                        es_result    = es_result     ).
     
         IF es_result-code = 200.
           "附件二进制下载
           IF iv_direct_down IS NOT INITIAL AND iv_filetype = 'BIN'.
     
     *         取得OBS key的文件名
             "根据Object key设置默认文件名
             CALL METHOD get_default_filename
               EXPORTING
                 iv_objectkey = iv_objectkey
               IMPORTING
                 ev_filename  = lv_filename
                 ev_extension = lv_extension.
     
             IF iv_default_filename IS NOT INITIAL.
               "使用OBS Key的后半部分作为文件名
               lv_filename = iv_default_filename. "使用外部传入的文件名
             ENDIF.
     
             CALL METHOD file_save_dialog
               EXPORTING
                 default_extension = lv_extension
                 default_file_name = lv_filename
               CHANGING
                 fullpath          = lv_filename
                 user_action       = lv_user_action
               EXCEPTIONS
                 error             = 1
                 OTHERS            = 2.
             IF sy-subrc <> 0 OR lv_user_action = 9.
               es_return = zcl_message=>convert_syst_to_bapiret2( ).
               RETURN.
             ENDIF.
     
     *       判断后缀名是否与服务器文件名一致
             REFRESH: lt_extension .
             SPLIT lv_filename AT '.' INTO TABLE lt_extension .
             CLEAR: lv_lines.
             DESCRIBE TABLE lt_extension LINES lv_lines.
             IF lv_lines > 0.
               READ TABLE lt_extension INTO DATA(lv_extension_t) INDEX lv_lines.
               IF sy-subrc EQ 0.
                 IF lv_extension_t <> lv_extension.
                   CONCATENATE lv_filename '.' lv_extension INTO lv_filename.
                 ENDIF.
               ELSE.
                 CONCATENATE lv_filename '.' lv_extension INTO lv_filename.
               ENDIF.
             ENDIF.
     
             CALL METHOD gui_download
               EXPORTING
                 iv_filename = lv_filename
                 iv_data     = es_result-rawbizdata
               EXCEPTIONS
                 error       = 1
                 OTHERS      = 2.
           ELSEIF iv_filetype = 'TEXT'."直接提取文本内容
     
             IF iv_newline IS NOT INITIAL.
               "LF换行
               SPLIT es_result-bizdata AT cl_abap_char_utilities=>newline INTO TABLE es_result-data[].
             ELSE.
               "CR_LF换行
               SPLIT es_result-bizdata AT cl_abap_char_utilities=>cr_lf INTO TABLE es_result-data[].
             ENDIF.
           ENDIF.
     
           "附件下载成功，ObjectKey为&1.
           MESSAGE s009 WITH iv_objectkey INTO lv_message.
           es_return = zcl_message=>convert_syst_to_bapiret2( ).
         ELSE.
           "附件下载失败，错误原因：&1&2
           MESSAGE e010 WITH es_result-code  es_result-reason INTO lv_message.
           es_return = zcl_message=>convert_syst_to_bapiret2( ).
         ENDIF.
     
       ENDMETHOD.
     ```

     

*  测试程序ZOBS_DEMO_ATTCH_DOWNLOAD

   ```ABAP
   *&---------------------------------------------------------------------*
   *& Report ZOBS_ATTCH_DOWNLOAD_TEST
   *&---------------------------------------------------------------------*
   *&
   *&---------------------------------------------------------------------*
   REPORT zobs_demo_attch_download.
   
   
   SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
     PARAMETERS: p_bucket TYPE zzbucket_obs DEFAULT 'mrm-attachment'.
     PARAMETERS: p_objkey TYPE zzobjectkey_obs .
     PARAMETERS: p_ftype  TYPE char10 DEFAULT 'BIN'.
     SELECTION-SCREEN COMMENT 50(50) TEXT-001 FOR FIELD p_ftype  ."默认BIN,直接下载文件内容TEXT
   
   SELECTION-SCREEN END OF BLOCK b1.
   
   
   START-OF-SELECTION.
     "下载文件
     PERFORM frm_download_attachment.
   
   *&---------------------------------------------------------------------*
   *& Form frm_download_attachment
   *&---------------------------------------------------------------------*
   *& text
   *&---------------------------------------------------------------------*
   *& -->  p1        text
   *& <--  p2        text
   *&---------------------------------------------------------------------*
   FORM frm_download_attachment.
     DATA: lo_obs       TYPE REF TO  zcl_obs,
           lv_filename  TYPE string,
           lv_objectkey TYPE string,
           ls_return    TYPE bapiret2.
   
   
     CREATE OBJECT lo_obs.
   
     lv_objectkey = p_objkey.
     IF p_ftype = 'BIN'.
       CALL METHOD lo_obs->download_attachment
         EXPORTING
           iv_bucketname = p_bucket
           iv_objectkey  = lv_objectkey
         IMPORTING
           es_return     = ls_return.
   
     ELSE.
   
       CALL METHOD lo_obs->download_attachment
         EXPORTING
           iv_bucketname = p_bucket
           iv_objectkey  = lv_objectkey
           iv_filetype   = 'TEXT'
           iv_newline    = 'X'
         IMPORTING
           es_return     = ls_return
           es_result     = DATA(ls_result).
   
   
       cl_demo_output=>display( data = ls_result-data ).
     ENDIF.
   
     IF ls_return IS NOT INITIAL..
       MESSAGE ID ls_return-id
             TYPE 'S'
           NUMBER ls_return-number
             WITH ls_return-message_v1
                  ls_return-message_v2
                  ls_return-message_v3
                  ls_return-message_v4 DISPLAY LIKE ls_return-type.
   
     ENDIF.
   ENDFORM.             
   ```


​            

#### 3.2.3 附件删除 DELETE_ATTACHMENT 

   -  附件上载使用DELETE方法;

   - 调用计算签名方法GET_SIGNTRUE；

   - 创建HTTP客户端，HOST需要包含Object Key；

   - 设置HTTP头域（Header）；

   - 发送请求，根据状态码=204判断文件是否删除成功（备注：如果删除的对象不存在，删除也是返回204）。

     ```ABAP
        METHOD delete_attachment.
     
         CALL METHOD delete_object
           EXPORTING
             iv_bucketname = iv_bucketname
             iv_objectkey  = iv_objectkey
           IMPORTING
             es_return     = es_return
             es_result     = es_result.
     
         "记录日志
         logging_obslog( is_return = es_return is_result = es_result ).
         "日志自动清理
         clear_obslog( ).
     
       ENDMETHOD.
     ```

     ```ABAP
       METHOD DELETE_OBJECT.
     
         DATA: lv_objectkey TYPE string,
               lv_message   TYPE bapi_msg.
     
         "设置桶信息
         set_bucket( iv_bucketname = iv_bucketname iv_objectkey = iv_objectkey ).
         "设置OBS操作
         set_action( c_action_delete ).
     
         CLEAR: lv_objectkey.
         lv_objectkey = iv_objectkey.
     
         CALL METHOD adjust_objectkey
           IMPORTING
             es_return    = es_return
           CHANGING
             cv_objectkey = lv_objectkey.
         IF es_return-type NA 'EAX'.
     
           "获取OBS的签名
           CLEAR:ms_signtrue_req         ,
                 es_return               ,
                 es_result               .
           ms_signtrue_req-bucketname             = iv_bucketname.
           ms_signtrue_req-httpmethod             = mv_http_method.
           ms_signtrue_req-authortype             = c_authortype_header.
           ms_signtrue_req-contenttype            = c_contenttype_bin .
           ms_signtrue_req-contentmd5             = ''.
           ms_signtrue_req-canonicalizeheaders    = ''.
           ms_signtrue_req-canonicalizeresource   = '/' && iv_bucketname && lv_objectkey.
     
           CALL METHOD get_signtrue
             EXPORTING
               is_signtrue_req = ms_signtrue_req
             IMPORTING
               es_return       = es_return.
         ENDIF.
     
         IF es_return-type NA 'EAX'.
     
           "采用HTTP Client访问OBS
           call_obs_httpclient( EXPORTING iv_objectkey = lv_objectkey
                                IMPORTING es_return    = es_return
                                          es_result    = es_result     ).
           IF es_result-code = 204. "
             "附件删除成功，ObjectKey为&1.
             MESSAGE s007 WITH iv_objectkey INTO lv_message.
             es_return = zcl_message=>convert_syst_to_bapiret2( ).
           ELSE.
             "附件删除失败，错误原因：&1&2
             MESSAGE e008 WITH es_result-code  es_result-reason INTO lv_message.
             es_return = zcl_message=>convert_syst_to_bapiret2( ).
           ENDIF.
         ENDIF.
       ENDMETHOD.
     ```

     

     

* 测试程序ZOBS_DEMO_ATTCH_DELETE

  ```ABAP
  *&---------------------------------------------------------------------*
  *& Report ZOBS_DEMO_ATTCH_DELETE
  *&---------------------------------------------------------------------*
  *&
  *&---------------------------------------------------------------------*
  REPORT zobs_demo_attch_delete.
  
  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
    PARAMETERS: p_bucket TYPE zzbucket_obs .
    PARAMETERS: p_objkey TYPE zzobjectkey_obs .
  SELECTION-SCREEN END OF BLOCK b1.
  
  START-OF-SELECTION.
    "上载文件
    PERFORM frm_delete_attachment .
  
  *&---------------------------------------------------------------------*
  *& Form frm_delete_attachment
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_delete_attachment .
    DATA: lo_obs       TYPE REF TO  zcl_obs,
          lv_filename  TYPE string,
          lv_objectkey TYPE string,
          ls_return    TYPE bapiret2,
          lv_message   TYPE string.
  
  
    CREATE OBJECT lo_obs.
  
    lv_objectkey = p_objkey.
  
    CALL METHOD lo_obs->delete_attachment
      EXPORTING
        iv_bucketname = p_bucket
        iv_objectkey  = lv_objectkey
      IMPORTING
        es_return     = ls_return
        es_result     = DATA(ls_result).
  
    IF ls_return IS NOT INITIAL..
      MESSAGE ID ls_return-id
            TYPE ls_return-type
          NUMBER ls_return-number
            WITH ls_return-message_v1
                 ls_return-message_v2
                 ls_return-message_v3
                 ls_return-message_v4.
    ENDIF.
  ENDFORM.
  ```

  

#### 3.2.4 文件内容下载 DOWNLOAD_FILE

  *此功能可以使用[附件下载](#3.2.2 附件下载 DOWNLOAD_ATTACHMENT )功能实现，只需要将FTYPE参数赋值为TEXT即可*

   - 1. 直接下载Text文件内容，请求方法使用GET;

   - 2. 调用计算签名方法GET_SIGNTRUE*（采用URL中携带签名的方式计算签名）*；

   - 3. 创建HTTP客户端，HOST需要包含Object Key和**授权信息**；

   - 4. 设置HTTP头域（Header），**不包含授权信息**；

   - 5. 发送请求，根据状态码=200判断文件是否下载成功。

   - 6. 将文件内容转换成String的内表*（根据传入的参数，决定Windows/linux的换行符）*

-  7. 源码实现

   ```ABAP
       METHOD download_file.
   
       DATA:  lv_objectkey TYPE string.
   
   
       "设置桶信息
       set_bucket( iv_bucketname = iv_bucketname iv_objectkey = iv_objectkey ).
       "设置OBS操作
       set_action( c_action_download ).
   
       "格式化对象Key
       CLEAR: lv_objectkey.
       lv_objectkey = iv_objectkey.
   
       CALL METHOD adjust_objectkey
         IMPORTING
           es_return    = es_return
         CHANGING
           cv_objectkey = lv_objectkey.
       IF es_return-type CA 'EAX'.
         "记录日志
         logging_obslog( is_return = es_return is_result = es_result ).
         RETURN.
       ENDIF.
   
       DO 50 TIMES.
   
         "获取OBS的签名
         CLEAR:ms_signtrue_req         ,
               es_return               ,
               es_result               .
         ms_signtrue_req-bucketname             = iv_bucketname.
         ms_signtrue_req-httpmethod             = mv_http_method.
         ms_signtrue_req-authortype             = c_authortype_url.
         ms_signtrue_req-contenttype            = c_contenttype_bin .
         ms_signtrue_req-contentmd5             = ''.
         ms_signtrue_req-canonicalizeheaders    = ''.
         ms_signtrue_req-canonicalizeresource   = '/' && iv_bucketname && lv_objectkey.
         CALL METHOD get_signtrue
           EXPORTING
             is_signtrue_req = ms_signtrue_req
           IMPORTING
             es_return       = es_return.
   
         IF es_return-type CA 'EAX'.
           "记录日志
           logging_obslog( is_return = es_return is_result = es_result ).
           RETURN.
         ENDIF.
   
         "采用HTTP Client访问OBS
         call_obs_httpclient( EXPORTING iv_objectkey = lv_objectkey
                              IMPORTING es_return    = es_return
                                        es_result    = es_result     ).
         IF es_result-code = 200.
           es_return-type       = 'S'.
           IF iv_newline IS NOT INITIAL.
             "LF换行
             SPLIT es_result-bizdata AT cl_abap_char_utilities=>newline INTO TABLE es_result-data[].
           ELSE.
             "CR_LF换行
             SPLIT es_result-bizdata AT cl_abap_char_utilities=>cr_lf INTO TABLE es_result-data[].
           ENDIF.
           EXIT.
         ELSEIF es_result-code = 404." Connection Refused 网络不通
           es_return-type       = 'E'.
           EXIT.
         ELSE.
           CLEAR: es_return.
           es_return-type       = 'E'.
   
           WAIT UP TO '0.1' SECONDS.
   
         ENDIF.
   
       ENDDO.
   
       "记录日志
       logging_obslog( is_return = es_return is_result = es_result ).
   
       "日志自动清理
       clear_obslog( ).
   
   
     ENDMETHOD.
   ```

- 测试程序 ZOBS_DEMO_TEXTFILE_DOWNLOAD

  ```ABAP
  *&---------------------------------------------------------------------*
  *& Report ZOBS_ATTCH_DOWNLOAD_TEST
  *&---------------------------------------------------------------------*
  *&
  *&---------------------------------------------------------------------*
  REPORT zobs_demo_textfile_download.
  
  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
    PARAMETERS: p_bucket TYPE zzbucket_obs.
    PARAMETERS: p_objkey TYPE zzobjectkey_obs .
  
  SELECTION-SCREEN END OF BLOCK b1.
  
  START-OF-SELECTION.
    "下载文件
    PERFORM frm_download_file.
  
  *&---------------------------------------------------------------------*
  *& Form frm_download_file
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM frm_download_file .
    DATA: lo_obs       TYPE REF TO  zcl_obs,
          lv_filename  TYPE string,
          lv_objectkey TYPE string,
          ls_return    TYPE bapiret2.
    CREATE OBJECT lo_obs.
  
    lv_objectkey = p_objkey.
  
    CALL METHOD lo_obs->download_file
      EXPORTING
        iv_bucketname = p_bucket
  *     iv_httpmethod = 'GET'
        iv_objectkey  = lv_objectkey
  *     iv_expires    = 3600
  *     iv_newline    = 'X'
      IMPORTING
        es_return     = ls_return
        es_result     = DATA(ls_result).
  
    IF ls_return IS NOT INITIAL..
      MESSAGE ID ls_return-id
            TYPE ls_return-type
          NUMBER ls_return-number
            WITH ls_return-message_v1
                 ls_return-message_v2
                 ls_return-message_v3
                 ls_return-message_v4.
  
    ENDIF.
  
    IF ls_return-type = 'S'.
      cl_demo_output=>display( data = ls_result-data ).
    ENDIF.
  
  
  ENDFORM.
  ```

  

#### 3.2.5 显示附件 DISPLAY_ATTACHMENT

  *此功能可以使用[附件下载](#3.2.2 附件下载 DOWNLOAD_ATTACHMENT )功能实现，将文件下载的二进制用HTML、OLE控件显示出来

   - 1. 调用计算签名方法GET_SIGNTRUE*（采用Header中携带签名的方式计算签名）*；

     2. 创建HTTP客户端，HOST需要包含Object Key和**授权信息**；

     3. 设置HTTP头域（Header），**包含授权信息**；

     4. 发送请求，根据状态码=200判断文件是否下载成功。

     5. 将文件内容转换成String的内表 *(根据传入的参数，决定Windows/linux的换行符）*

     6. 源码实现

        ```ABAP
          METHOD display_attachment.
            DATA: lv_type     TYPE text20,
                  lv_subtype  TYPE text20,
                  lv_filename TYPE string.
        
            "下载附件
            CALL METHOD download_object
              EXPORTING
                iv_bucketname  = iv_bucketname
                iv_objectkey   = iv_objectkey
                iv_filetype    = 'BIN'
                iv_direct_down = ''
              IMPORTING
                es_return      = es_return
                es_result      = DATA(ls_result).
            IF es_return-type CA 'EAX'.
              RETURN.
            ENDIF.
        
            "显示附件
            DATA(lv_apptype) = get_application_type( EXPORTING
                                                       iv_dockey  = iv_objectkey
                                                     IMPORTING
                                                       ex_type    = lv_type
                                                       ex_subtype = lv_subtype ).
        
        
            IF lv_type = 'text'.
              CALL METHOD zcl_obs=>text_convert
                CHANGING
                  cv_data = ls_result-rawbizdata.
            ENDIF.
        
            CASE lv_apptype.
              WHEN app_type_html.
                IF iv_dialog IS INITIAL.
                  CALL FUNCTION 'ZFM_OBS_DISPLAY_HTML'
                    EXPORTING
                      iv_data     = ls_result-rawbizdata
                      iv_type     = lv_type
                      iv_subtype  = lv_subtype
                      iv_filename = iv_objectkey.
                ELSE.
                  CALL METHOD html_show
                    EXPORTING
                      iv_data     = ls_result-rawbizdata
                      iv_type     = lv_type
                      iv_subtype  = lv_subtype
                      iv_filename = iv_objectkey.
        
                ENDIF.
        
              WHEN app_type_ole.
                IF iv_dialog IS INITIAL.
                  CALL FUNCTION 'ZFM_OBS_DISPLAY_OLE'
                    EXPORTING
                      iv_data     = ls_result-rawbizdata
                      iv_type     = lv_type
                      iv_subtype  = lv_subtype
                      iv_filename = iv_objectkey.
        
                ELSE.
                  CALL METHOD ole_show
                    EXPORTING
                      iv_data     = ls_result-rawbizdata
                      iv_type     = lv_type
                      iv_subtype  = lv_subtype
                      iv_filename = iv_objectkey.
                ENDIF.
        
              WHEN OTHERS.
                MESSAGE i000 WITH '不支持打开此类型的文件。'(001).
                RETURN.
            ENDCASE.
          ENDMETHOD.
        ```

     7. 测试程序

        ```ABAP
        *&---------------------------------------------------------------------*
        *& Report ZOBS_ATTCH_DOWNLOAD_TEST
        *&---------------------------------------------------------------------*
        *&
        *&---------------------------------------------------------------------*
        REPORT zobs_demo_attch_display.
        
        
        SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
          PARAMETERS: p_bucket TYPE zzbucket_obs DEFAULT 'mrm-attachment'.
          PARAMETERS: p_objkey TYPE zzobjectkey_obs .
        
        SELECTION-SCREEN END OF BLOCK b1.
        
        
        
        START-OF-SELECTION.
          "显示对象
          PERFORM frm_display_attachment.
        
        *&---------------------------------------------------------------------*
        *& Form frm_display_attachment
        *&---------------------------------------------------------------------*
        *& text
        *&---------------------------------------------------------------------*
        *& -->  p1        text
        *& <--  p2        text
        *&---------------------------------------------------------------------*
        FORM frm_display_attachment.
          DATA: lo_obs        TYPE REF TO  zcl_obs,
                lv_objectkey  TYPE string,
                lv_destobject TYPE string,
                ls_return     TYPE bapiret2.
        
        
          CREATE OBJECT lo_obs.
        
          lv_objectkey = p_objkey.
        
          CALL METHOD lo_obs->display_attachment
            EXPORTING
              iv_bucketname = p_bucket
              iv_objectkey  = lv_objectkey
              iv_dialog     = abap_false   "选择屏幕调用，参数设为空
            IMPORTING
              es_return     = ls_return.
        
          IF ls_return IS NOT INITIAL..
            MESSAGE ID ls_return-id
                  TYPE ls_return-type
                NUMBER ls_return-number
                  WITH ls_return-message_v1
                       ls_return-message_v2
                       ls_return-message_v3
                       ls_return-message_v4.
        
          ENDIF.
        
        
        
        ENDFORM.
        
        ```

        

        ​	

#### 3.2.6 复制附件

##### 	3.2.6.1 两步法：先下载再上载 COPY_ATTACHMENT_NEW

​	*由于华为云OBS API调用有问题，采用临时方案，先将文件下载，再将文件上载成另外一个对象***

1. 先调用下载方法，获取文件的二进制；

2. 将获取的二进制上载到新的对象Key；

3. 源码实现

   ```ABAP
   **/
   *----------------------------------------------------------------------*
   * 复制对象的结果不能仅根据HTTP返回头域中的status_code来判断请求是否成功，
   * 头域中status_code返回200时表示服务端已经收到请求，且开始处理复制对象请求。
   * 复制是否成功会在响应消息的body中，只有body体中有ETag标签才表示成功，
   * 否则表示复制失败。
   *----------------------------------------------------------------------*
   */
   METHOD copy_attachment_new.
   
   
     DATA: lv_data       TYPE xstring,
           lv_filelength TYPE i,
           lv_message    TYPE bapi_msg.
   
   
   
     "下载源文件
     "下载附件
     CALL METHOD download_object
       EXPORTING
         iv_bucketname  = iv_sourcebucket
         iv_objectkey   = iv_sourceobject
         iv_filetype    = 'BIN'
         iv_direct_down = ''
       IMPORTING
         es_return      = es_return
         es_result      = es_result.
     IF es_return-type CA 'EAX'.
       RETURN.
     ENDIF.
   
     lv_data = es_result-rawbizdata.
   
     "上载目标文件
     CALL METHOD upload_object
       EXPORTING
         iv_bucketname = iv_destbucket
         iv_objectkey  = iv_destobject
         iv_data       = lv_data
       IMPORTING
         es_return     = es_return
         es_result     = es_result.
   
     IF es_result-code = 200.
       "附件上载成功，ObjectKey为&1.
       MESSAGE s013 WITH iv_destobject INTO lv_message.
       es_return = zcl_message=>convert_syst_to_bapiret2( ).
     ELSE.
       "附件上载失败，错误原因：&1&2
       MESSAGE e014 WITH es_result-code es_result-reason INTO lv_message.
       es_return = zcl_message=>convert_syst_to_bapiret2( ).
     ENDIF.
   
     "设置OBS操作
     set_action( c_action_copy ).
   
     "记录日志
     logging_obslog( is_return = es_return is_result = es_result ).
     "日志自动清理
     clear_obslog( ).
   
   ENDMETHOD.
   ```

   

#####  3.2.6.2 一步法：直接调用OBS复制功能COPY_ATTACHMENT

   -  复制对象使用PUT方法;

   - 调用计算签名方法；

     计算签名的参数CanonicalizedHeaders中需要包含参数x-obs-copy-source。

     > 参数x-obs-copy-source
     >
     > 用来指定复制对象操作的源桶名以及源对象名。当源对象存在多个版本时，通过versionId参数指定版本源对象。
     >
     > 类型：String
     >
     > 约束：中文字符，需要进行URLEncode
     >
     > 示例：x-obs-copy-source: /source_bucket/sourceObject

   - 创建HTTP客户端，HOST需要包含Object Key；

   - 设置HTTP头域（Header）；

   - 发送请求，并提取返回的结果。

##### 3.2.6.3 测试程序

```ABAP
*&---------------------------------------------------------------------*
*& Report ZOBS_ATTCH_DOWNLOAD_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zobs_demo_attch_copy.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
  PARAMETERS: p_srcbkt TYPE zzbucket_obs DEFAULT 'sap-mm-attachment '.
  PARAMETERS: p_srcobj TYPE zzobjectkey_obs.
  PARAMETERS: p_dstbkt TYPE zzbucket_obs DEFAULT 'sap-mm-attachment '.
  PARAMETERS: p_dstobj TYPE zzobjectkey_obs.
  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-s02.
    PARAMETERS: p_copy1 RADIOBUTTON GROUP gp1.
    PARAMETERS: p_copy2 RADIOBUTTON GROUP gp1 DEFAULT 'X'.
  SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  "复制对象
  PERFORM frm_copy_attachment.

*&---------------------------------------------------------------------*
*& Form frm_copy_attachment
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_copy_attachment.
  DATA: lo_obs          TYPE REF TO  zcl_obs,
        lv_sourceobject TYPE string,
        lv_destobject   TYPE string,
        ls_return       TYPE bapiret2,
        ls_result       TYPE zobss_result.


  CREATE OBJECT lo_obs.

  lv_sourceobject = p_srcobj.
  lv_destobject   = p_dstobj.

  IF p_copy1 IS NOT INITIAL.
    "直接调用华为云OBS的复制方法
    CALL METHOD lo_obs->copy_attachment
      EXPORTING
        iv_sourcebucket = p_srcbkt
        iv_sourceobject = lv_sourceobject
        iv_destbucket   = p_dstbkt
        iv_destobject   = lv_destobject
      IMPORTING
        es_return       = ls_return
        es_result       = ls_result.
  ELSE.
    "先下载再上载
    CALL METHOD lo_obs->copy_attachment_new
      EXPORTING
        iv_sourcebucket = p_srcbkt
        iv_sourceobject = lv_sourceobject
        iv_destbucket   = p_dstbkt
        iv_destobject   = lv_destobject
      IMPORTING
        es_return       = ls_return
        es_result       = ls_result.
  ENDIF.

  IF ls_return IS NOT INITIAL..
    MESSAGE ID ls_return-id
          TYPE 'S'
        NUMBER ls_return-number
          WITH ls_return-message_v1
               ls_return-message_v2
               ls_return-message_v3
               ls_return-message_v4
               DISPLAY LIKE ls_return-type.

  ENDIF.



ENDFORM.
```



### 3.3 桶的基本操作

#### 3.3.1 列举桶内对象

对桶拥有读权限的用户可以执行获取桶内对象列表的操作。

如果用户在请求的URI里只指定了桶名，即GET /BucketName，则返回信息中会包含桶内部分或所有对象的描述信息（一次最多返回1000个对象信息）；如果用户还指定了prefix、marker、max-keys、delimiter参数中的一个或多个，则返回的对象列表将按照如[表1](https://support.huaweicloud.com/api-obs/obs_04_0022.html#obs_04_0022__table14681180)所示规定的语义返回指定的对象。

由于每次最多返回1000个文件，需要根据上次返回的NextMarker参数循环调用才能获取完整的对象列表。

列举桶内对象的方法LIST_BUCKET_OBJECTS

##### 3.3.1.1 列举桶内对象采用GET方法

##### 3.3.1.2 计算签名

访问桶内的对象清单是对桶的操作，所以请求访问的资源参数CanonicalizedResource指定为/BucketName/

```ABAP
"获取OBS的签名
CLEAR:ms_signtrue_req         ,
      es_return               .
ms_signtrue_req-bucketname             = iv_bucketname.
ms_signtrue_req-httpmethod             = mv_http_method.
ms_signtrue_req-authortype             = c_authortype_header.
ms_signtrue_req-contenttype            = '' .
ms_signtrue_req-contentmd5             = ''.
ms_signtrue_req-canonicalizeheaders    = ''.
ms_signtrue_req-canonicalizeresource   = '/'  && iv_bucketname && '/' .
```



##### 3.3.1.3 设置HTTP头域

```http
Date: date
Authorization: authorization
```

==经过测试发现，Date一定要在Authorization，否则会报错，应该是OBS后端的设置导致的。==

##### 3.3.1.4 设置url

经测试发现，前缀prefix和起始标识marker只有拼接在URL中才生效。

> prefix：列举以指定的字符串prefix开头的对象
>
> marker：列举桶内对象列表时，指定一个标识符，从该标识符以后按字典顺序返回对象列表。等于上一次返回的NextMarker。
>
> NextMarker：如果本次没有返回全部结果，响应请求中将包含此字段，用于标明本次请求列举到的最后一个对象。后续请求可以指定Marker等于该值来列举剩余的对象。

```ABAP
CLEAR: me->mt_parameters.

  me->mt_parameters = VALUE #(
   ( name = 'prefix'      value = iv_prefix      )
   ( name = '&marker'     value = lv_nextmarker  )
   ).
```

##### 3.3.1.5 调用HTTP返回对象清单

##### 3.3.1.6 解析返回的XML文件

 

```ABAP
  METHOD parse_list_bucket_result.

    DATA: lr_ixml          TYPE REF TO if_ixml,
          lr_streamfactory TYPE REF TO if_ixml_stream_factory,
          lr_parser        TYPE REF TO if_ixml_parser,
          lr_istram        TYPE REF TO if_ixml_istream,
          lr_document      TYPE REF TO if_ixml_document.
    "create main ixml factory
    lr_ixml = cl_ixml=>create(  ).

    "create a stream factory
    lr_streamfactory = lr_ixml->create_stream_factory( ).

    lr_istram = lr_streamfactory->create_istream_string( xmldata ).

    "create a document
    lr_document = lr_ixml->create_document( ).

    "Creates a parser
    lr_parser = lr_ixml->create_parser( document       = lr_document
                                        istream        = lr_istram
                                        stream_factory = lr_streamfactory
                                       ).

    IF lr_parser->parse( ) NE 0."Full parsing of input stream into a DOM.

      IF lr_parser->num_errors( ) <> 0."
        RETURN.
      ENDIF.

    ENDIF.


    IF lr_parser->is_dom_generating( ) = abap_true. "DOM是否生成

      "解析DOM
      is_truncated = parse_dom_document(
        EXPORTING
          document   = lr_document
        IMPORTING
          nextmarker = nextmarker ).

    ENDIF.

  ENDMETHOD.
```

 

```ABAP
  METHOD parse_dom_document.

    DATA: lr_node     TYPE REF TO if_ixml_node,
          lr_iterator TYPE REF TO if_ixml_node_iterator,
          lr_node_map TYPE REF TO if_ixml_named_node_map,
          lv_name     TYPE string,
          lv_value    TYPE string.

    lr_node ?= document.


    CHECK lr_node IS NOT INITIAL.

    "创建一个节点迭代器
    lr_iterator = lr_node->create_iterator(   ).

    "获取当前节点
    lr_node = lr_iterator->get_next( ).

    "循环所有节点
    WHILE lr_node IS NOT INITIAL.

      CASE lr_node->get_type( ).
        WHEN if_ixml_node=>co_node_element.
          lv_name = to_upper( lr_node->get_name( ) ).
          IF lv_name = 'CONTENTS'.
            APPEND INITIAL LINE TO me->mt_object_list ASSIGNING FIELD-SYMBOL(<lfs_object_list>).

          ENDIF.
        WHEN if_ixml_node=>co_node_text OR
              if_ixml_node=>co_node_cdata_section.
          lv_value = lr_node->get_value( ).


          CASE lv_name.
            WHEN 'ISTRUNCATED'.
              is_truncated = lv_value.
            WHEN 'NEXTMARKER'.
              nextmarker = lv_value.
            WHEN OTHERS.

              IF <lfs_object_list> IS  ASSIGNED.
                ASSIGN COMPONENT lv_name OF STRUCTURE <lfs_object_list> TO FIELD-SYMBOL(<lfs_field>).
                IF sy-subrc EQ 0.
                  <lfs_field> = lv_value.
                ENDIF.
              ENDIF.


          ENDCASE.

        WHEN OTHERS.
      ENDCASE.
      "获取下一个节点
      lr_node = lr_iterator->get_next( ).
    ENDWHILE.
  ENDMETHOD.
```



##### 3.3.1.7 源码实现



```ABAP
METHOD list_bucket_objects.
  DATA: lv_message    TYPE bapi_msg.

  DATA: lv_filename    TYPE string,
        lv_extension   TYPE string,
        lv_objectkey   TYPE string,
        lv_user_action TYPE i,
        lv_action      TYPE zzaction_obs,
        ls_return	     TYPE bapiret2,
        ls_result	     TYPE zobss_result,
        lv_nextmarker  TYPE zzobs_nextmarker,
        lv_lines       TYPE i.

  set_bucket( iv_bucketname = iv_bucketname )."设置桶信息

  set_action( me->c_action_getobjlist )."设置OBS操作

  "获取OBS的签名
  CLEAR:ms_signtrue_req         ,
        es_return               .

  ms_signtrue_req-bucketname             = iv_bucketname.
  ms_signtrue_req-httpmethod             = mv_http_method.
  ms_signtrue_req-authortype             = c_authortype_header.
  ms_signtrue_req-contenttype            = '' .
  ms_signtrue_req-contentmd5             = ''.
  ms_signtrue_req-canonicalizeheaders    = ''.
  ms_signtrue_req-canonicalizeresource   = '/'  && iv_bucketname && '/' .
  CLEAR: lv_nextmarker,
         me->mt_object_list.
  DO.

    CALL METHOD get_signtrue
      EXPORTING
        is_signtrue_req = ms_signtrue_req
      IMPORTING
        es_return       = es_return.

    IF es_return-type CA 'EAX'.
      EXIT.
    ENDIF.

    CLEAR: me->mt_http_header.
    me->mt_http_header = VALUE #( BASE  me->mt_http_header ( name = '~request_method' vaule = me->mv_http_method ) ). " 请求方法
    me->mt_http_header = VALUE #( BASE  me->mt_http_header ( name = 'Date' vaule = ms_signtrue-date ) ). " 日期
    me->mt_http_header = VALUE #( BASE  me->mt_http_header ( name = 'Authorization' vaule = ms_signtrue-authorization ) ). "CLEAR: me->mt_parameters.

    me->mt_parameters = VALUE #(
     ( name = 'prefix'      value = iv_prefix      )
     ( name = '&marker'     value = lv_nextmarker  )
     ).

    "采用HTTP Client访问OBS
    me->get_obs_object_list(
      EXPORTING
        iv_bucketname = iv_bucketname
        it_parameters = me->mt_parameters
      IMPORTING
        es_return     = ls_return
        es_result     = ls_result ).

    IF ls_result-code = 200.
      "获取桶&1对象列表成功.
      MESSAGE s016 WITH iv_bucketname INTO lv_message.
      es_return = zcl_message=>convert_syst_to_bapiret2( ).

      "解析XML，获取文件列表
      IF me->parse_list_bucket_result(
        EXPORTING
          xmldata = ls_result-bizdata
        IMPORTING
          nextmarker = lv_nextmarker ) <> me->c_true.

        "如果解析出的XML文件中的IsTruncated=false时，标识已经返回全部结果，则终止循环
        EXIT.
      ENDIF.
    ELSE.
      "获取桶&1对象列表失败，错误原因：&1&2
      MESSAGE e017 WITH ls_result-code  ls_result-reason INTO lv_message.
      es_return = zcl_message=>convert_syst_to_bapiret2( ).
      EXIT.
    ENDIF.
  ENDDO.

  rt_object_list = me->mt_object_list. 
ENDMETHOD.
```



##### 3.3.1.8 测试程序

```ABAP
*&---------------------------------------------------------------------*
*& Report ZOBS_DEMO_LIST_BUCKET_OBJECTS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zobs_demo_list_bucket_objects NO STANDARD PAGE HEADING MESSAGE-ID zobs.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
  PARAMETERS: p_bucket TYPE zzbucket_obs DEFAULT 'sap-mm-attachment'.
  PARAMETERS: p_prefix TYPE zzprefix_obs DEFAULT ''.

SELECTION-SCREEN END OF BLOCK b1.


START-OF-SELECTION.

  PERFORM frm_get_object_list.


*&---------------------------------------------------------------------*
*& Form frm_GET_OBJECT_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_get_object_list .
  DATA: ls_return	TYPE bapiret2,
        ls_result	TYPE zobss_result.

  DATA(lr_obs) = zcl_obs=>factory( ).

  DATA(lt_object_list) = lr_obs->list_bucket_objects(
    EXPORTING
      iv_bucketname = p_bucket                 " OBS桶
      iv_prefix     = p_prefix
    IMPORTING
      es_return     = ls_return               " 返回参数
  ).

  
  IF lt_object_list IS NOT INITIAL.
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = gr_table
          CHANGING
            t_table      = lt_object_list
        ).

        gr_salv = zcl_salv=>factory( ).
        gr_salv->display(
          EXPORTING
            ir_table = gr_table
          CHANGING
            ct_data  = lt_object_list
        ).

      CATCH cx_salv_msg. " ALV: General Error Class with Message

    ENDTRY.
  ENDIF.

ENDFORM.
```

![image-20221105113703546](https://github.com/liangzihua/sap2obs/blob/main/image/image-20221105113703546.png)

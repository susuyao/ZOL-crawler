任务计划
===

## 数据预处理

把excel中的设备信息读取到数据库中

## url解析

`http://search.zol.com.cn/s/all.php?kword=%C8%FD%D0%C7GALAXY+S7+Edge`
首先在url后面的kword拼接设备的信息组成一个新的url,查看页面中是否包含更多参数这个按钮,如果没有的话要入数据库,后续手动处理这些数据
最终得到所有参数的链接的url;

## 内容入库

通过url访问页面,开始抓取所需的参数信息,入库,没有的参数信息要留空;
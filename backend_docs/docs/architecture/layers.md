# 分层说明

DocuSnap-Backend 系统采用了清晰的分层架构，每一层都有明确的职责和功能。本页面详细介绍系统的各个层次及其职责。

## 架构分层概述

DocuSnap-Backend 的架构可以分为以下几个主要层次：

1. **API 层**：处理客户端请求和响应
2. **业务逻辑层**：实现核心业务功能
3. **服务集成层**：与外部服务（OCR、LLM）交互
4. **数据访问层**：管理数据存储和检索
5. **安全层**：提供安全机制和数据保护

这种分层设计有助于实现关注点分离，使系统更加模块化、可维护和可扩展。

## API 层

API 层是系统与客户端交互的接口，负责处理 HTTP 请求和响应。

### 主要职责

- 提供 RESTful API 接口
- 解析和验证客户端请求
- 路由请求到适当的处理函数
- 格式化和返回响应数据
- 处理错误和异常

### 关键组件

- **Flask 应用**：提供 Web 服务框架
- **路由定义**：映射 URL 到处理函数
- **请求解析**：解析 HTTP 请求参数和内容
- **响应生成**：构建 HTTP 响应

### 代码示例

```python
@app.route('/api/process_document', methods=['POST'])
def process_document():
    # 解析和验证请求
    if not request.is_json:
        return jsonify({"error": "请求必须是JSON格式"}), 400
    
    data = request.get_json()
    
    # 参数验证
    if 'images' not in data or not isinstance(data['images'], list):
        return jsonify({"error": "缺少images参数或格式不正确"}), 400
    
    # 处理请求并返回响应
    # ...
    
    return jsonify(response_data), 200
```

## 业务逻辑层

业务逻辑层实现系统的核心功能，包括任务处理、文档分析和表单处理等。

### 主要职责

- 实现核心业务功能和处理逻辑
- 协调任务处理和工作流程
- 管理任务队列和工作线程
- 实现不同类型任务的处理策略

### 关键组件

- **任务队列**：存储待处理的任务
- **工作线程**：执行任务处理
- **处理策略**：针对不同任务类型的处理逻辑
- **结果处理**：处理和格式化任务结果

### 代码示例

```python
def worker():
    """工作线程函数，从队列获取任务并处理"""
    while True:
        task = task_queue.get()
        try:
            # 根据任务类型选择处理策略
            if task['type'] == 'document':
                process_document_task(task)
            elif task['type'] == 'form':
                process_form_task(task)
            elif task['type'] == 'form_filling':
                process_form_filling_task(task)
        except Exception as e:
            # 错误处理
            update_task_status(task['id'], 'error', str(e))
        finally:
            task_queue.task_done()
```

## 服务集成层

服务集成层负责与外部服务（如 OCR 服务和 LLM 服务）的交互，封装外部服务的调用细节。

### 主要职责

- 与 OCR 服务通信，处理图像识别
- 与 LLM 服务通信，处理文本分析
- 管理外部服务的请求和响应
- 处理服务调用的错误和异常

### 关键组件

- **OCR 客户端**：与 OCR 服务交互
- **LLM 客户端**：与 LLM 服务交互
- **请求构建**：构建外部服务请求
- **响应解析**：解析外部服务响应

### 代码示例

```python
def call_llm_api(prompt, max_tokens=4096):
    """调用 LLM API 处理提示"""
    try:
        response = zhipuai.model_api.invoke(
            model="chatglm_pro",
            prompt=prompt,
            temperature=0.7,
            max_tokens=max_tokens
        )
        
        if response['code'] == 200:
            return response['data']['choices'][0]['content']
        else:
            raise Exception(f"LLM API 调用失败: {response['msg']}")
    except Exception as e:
        # 错误处理
        raise Exception(f"LLM API 调用异常: {str(e)}")
```

## 数据访问层

数据访问层负责管理系统的数据存储和检索，包括任务状态、处理结果和缓存数据。

### 主要职责

- 管理 SQLite 数据库连接
- 存储和检索任务状态和结果
- 实现缓存机制，避免重复计算
- 定期清理过期数据

### 关键组件

- **数据库连接**：管理 SQLite 连接
- **数据模型**：定义数据结构和关系
- **查询函数**：执行数据库查询
- **缓存管理**：管理缓存数据的存储和清理

### 代码示例

```python
def get_task_result(task_id):
    """从数据库获取任务结果"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute(
        "SELECT status, result, created_at FROM tasks WHERE id = ?",
        (task_id,)
    )
    
    task = cursor.fetchone()
    conn.close()
    
    if task:
        return {
            'status': task[0],
            'result': task[1],
            'created_at': task[2]
        }
    else:
        return None
```

## 安全层

安全层提供系统的安全机制，包括加密、认证、授权和数据保护。

### 主要职责

- 实现端到端加密
- 验证请求的完整性和真实性
- 保护敏感数据的安全
- 防止未授权访问和数据泄露

### 关键组件

- **RSA 加密**：用于密钥交换
- **AES 加密**：用于数据加密
- **哈希验证**：验证数据完整性
- **参数验证**：验证请求参数

### 代码示例

```python
def decrypt_request(encrypted_data, encrypted_key, signature):
    """解密请求数据并验证完整性"""
    try:
        # 使用私钥解密 AES 密钥
        private_key = load_private_key()
        aes_key = rsa_decrypt(encrypted_key, private_key)
        
        # 使用 AES 密钥解密数据
        data = aes_decrypt(encrypted_data, aes_key)
        
        # 验证签名
        computed_hash = sha256_hash(data)
        if computed_hash != signature:
            raise Exception("签名验证失败")
        
        return json.loads(data)
    except Exception as e:
        # 错误处理
        raise Exception(f"请求解密失败: {str(e)}")
```

## 层间交互

DocuSnap-Backend 的各层之间通过明确的接口和数据流进行交互，形成一个协调工作的整体。

### 主要交互流程

1. **API 层 → 业务逻辑层**：
   - API 层接收客户端请求，解析后传递给业务逻辑层
   - 业务逻辑层处理完成后，将结果返回给 API 层

2. **业务逻辑层 → 服务集成层**：
   - 业务逻辑层需要 OCR 或 LLM 服务时，调用服务集成层
   - 服务集成层返回处理结果给业务逻辑层

3. **业务逻辑层 → 数据访问层**：
   - 业务逻辑层需要存储或检索数据时，调用数据访问层
   - 数据访问层返回查询结果给业务逻辑层

4. **安全层与其他层**：
   - 安全层横跨其他所有层，提供安全服务
   - API 层使用安全层解密和验证请求
   - 业务逻辑层使用安全层保护敏感数据
   - 数据访问层使用安全层加密存储数据

### 数据流向

系统中的数据流向可以概括为：

1. **输入流**：客户端 → API 层 → 业务逻辑层 → 服务集成层 → 外部服务
2. **输出流**：外部服务 → 服务集成层 → 业务逻辑层 → API 层 → 客户端
3. **数据存储流**：业务逻辑层 → 数据访问层 → 数据库
4. **数据检索流**：数据库 → 数据访问层 → 业务逻辑层

## 分层架构的优势

DocuSnap-Backend 的分层架构带来了以下优势：

1. **关注点分离**：每一层专注于特定的职责，减少耦合
2. **可维护性**：易于理解、修改和扩展各层功能
3. **可测试性**：可以独立测试每一层的功能
4. **灵活性**：可以替换或升级特定层的实现，而不影响其他层
5. **可重用性**：通用功能可以在不同模块中重用

通过这种分层设计，DocuSnap-Backend 实现了一个结构清晰、功能明确、易于维护和扩展的系统架构。
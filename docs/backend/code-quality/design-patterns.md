# 设计模式

DocuSnap-Backend 系统中应用了多种设计模式，这些模式帮助提高了代码的可维护性、可扩展性和灵活性。本页面详细介绍系统中使用的主要设计模式及其实现方式。

## 生产者-消费者模式

生产者-消费者模式是 DocuSnap-Backend 系统中最核心的设计模式之一，用于实现异步任务处理。

### 实现方式

系统使用 Python 的 `Queue` 类和线程实现生产者-消费者模式：

1. **生产者**：
   - API 端点（如 `process_document`、`process_form` 等）作为生产者
   - 接收客户端请求，创建任务，并将任务添加到队列

2. **消费者**：
   - 工作线程作为消费者
   - 从队列获取任务并处理
   - 多个工作线程并行工作，提高处理效率

3. **队列**：
   - 使用 Python 的 `Queue` 类实现线程安全的任务队列
   - 解耦任务生成和执行
   - 支持异步处理和并发控制

**代码示例**：

```python
# 初始化任务队列
task_queue = Queue()

# 生产者：API 端点
@app.route('/api/process_document', methods=['POST'])
def process_document():
    # ... 请求验证和解密 ...
    
    # 创建任务
    task_id = str(uuid.uuid4())
    task = {
        'id': task_id,
        'type': 'document',
        'data': decrypted_data
    }
    
    # 添加任务到队列（生产者行为）
    add_task_to_queue(task)
    
    # 返回任务 ID
    return jsonify({'task_id': task_id}), 202

# 消费者：工作线程
def worker():
    """工作线程函数，从队列获取任务并处理"""
    while True:
        # 从队列获取任务（消费者行为）
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
            # 标记任务完成
            task_queue.task_done()
```

### 优势

1. **解耦**：生产者和消费者之间通过队列解耦，减少相互依赖
2. **并发处理**：多个消费者可以并行处理任务，提高系统吞吐量
3. **负载均衡**：任务队列自动在多个工作线程之间分配任务
4. **异步处理**：客户端不需要等待任务完成，提高响应速度

## 策略模式

策略模式用于根据任务类型选择不同的处理策略，使系统能够灵活处理不同类型的任务。

### 实现方式

系统根据任务类型（`document`、`form`、`form_filling`）选择不同的处理函数：

1. **策略接口**：
   - 不同的处理函数具有相似的接口（接受任务对象作为参数）
   - 每个处理函数负责特定类型任务的处理逻辑

2. **策略选择**：
   - 工作线程根据任务类型选择适当的处理函数
   - 使用简单的条件语句进行选择

3. **策略实现**：
   - 每种任务类型对应一个处理函数
   - 处理函数实现特定类型任务的处理逻辑

**代码示例**：

```python
# 策略选择
def worker():
    while True:
        task = task_queue.get()
        try:
            # 根据任务类型选择处理策略
            if task['type'] == 'document':
                process_document_task(task)  # 文档处理策略
            elif task['type'] == 'form':
                process_form_task(task)      # 表单处理策略
            elif task['type'] == 'form_filling':
                process_form_filling_task(task)  # 表单填充策略
        except Exception as e:
            update_task_status(task['id'], 'error', str(e))
        finally:
            task_queue.task_done()

# 文档处理策略
def process_document_task(task):
    """处理文档类型的任务"""
    update_task_status(task['id'], 'processing')
    
    try:
        # 文档处理特定逻辑
        ocr_results = process_images(task['data']['images'])
        prompt = build_document_prompt(ocr_results)
        llm_result = call_llm_api(prompt)
        parsed_result = parse_document_result(llm_result)
        
        update_task_status(task['id'], 'completed', parsed_result)
    except Exception as e:
        update_task_status(task['id'], 'error', str(e))
        raise

# 表单处理策略
def process_form_task(task):
    """处理表单类型的任务"""
    # 表单处理特定逻辑
    # ...

# 表单填充策略
def process_form_filling_task(task):
    """处理表单填充类型的任务"""
    # 表单填充特定逻辑
    # ...
```

### 优势

1. **灵活性**：可以轻松添加新的任务类型和处理策略
2. **可维护性**：每种策略独立实现，便于维护和修改
3. **开闭原则**：添加新策略不需要修改现有代码
4. **单一职责**：每个策略函数专注于特定类型的任务处理

## 工厂方法模式

工厂方法模式用于创建不同类型的提示（Prompt），根据任务类型生成适当的提示模板。

### 实现方式

系统使用不同的函数构建不同类型的提示：

1. **工厂方法**：
   - 不同的提示构建函数作为工厂方法
   - 每个函数负责创建特定类型的提示

2. **产品**：
   - 提示字符串作为产品
   - 不同类型的提示有不同的结构和内容

3. **客户端**：
   - 任务处理函数作为客户端
   - 根据任务类型选择适当的工厂方法

**代码示例**：

```python
# 文档提示工厂方法
def build_document_prompt(ocr_text):
    """构建文档处理的提示"""
    # 从 prompts.py 获取文档处理提示模板
    prompt_template = DOCUMENT_PROMPT_TEMPLATE
    
    # 将 OCR 文本插入提示模板
    prompt = prompt_template.format(document_text='\n'.join(ocr_text))
    
    return prompt

# 表单提示工厂方法
def build_form_prompt(ocr_text):
    """构建表单处理的提示"""
    # 从 prompts.py 获取表单处理提示模板
    prompt_template = FORM_PROMPT_TEMPLATE
    
    # 将 OCR 文本插入提示模板
    prompt = prompt_template.format(form_text='\n'.join(ocr_text))
    
    return prompt

# 表单填充提示工厂方法
def build_form_filling_prompt(ocr_text, user_data):
    """构建表单填充的提示"""
    # 从 prompts.py 获取表单填充提示模板
    prompt_template = FORM_FILLING_PROMPT_TEMPLATE
    
    # 将 OCR 文本和用户数据插入提示模板
    prompt = prompt_template.format(
        form_text='\n'.join(ocr_text),
        user_data=json.dumps(user_data, ensure_ascii=False)
    )
    
    return prompt

# 客户端使用
def process_document_task(task):
    ocr_results = process_images(task['data']['images'])
    # 使用文档提示工厂方法
    prompt = build_document_prompt(ocr_results)
    llm_result = call_llm_api(prompt)
    # ...

def process_form_task(task):
    ocr_results = process_images(task['data']['images'])
    # 使用表单提示工厂方法
    prompt = build_form_prompt(ocr_results)
    llm_result = call_llm_api(prompt)
    # ...
```

### 优势

1. **封装创建逻辑**：提示创建逻辑封装在工厂方法中，客户端不需要了解具体细节
2. **灵活性**：可以轻松添加新类型的提示
3. **可维护性**：提示模板集中管理，便于修改和优化
4. **代码复用**：避免重复的提示构建代码

## 代理模式

代理模式用于实现缓存机制，避免重复计算，提高系统性能。

### 实现方式

系统使用缓存作为处理结果的代理：

1. **主体**：
   - 实际的处理逻辑（OCR 处理和 LLM 处理）

2. **代理**：
   - 缓存机制作为代理
   - 在访问主体之前检查缓存
   - 如果缓存命中，直接返回缓存结果，避免调用主体

3. **客户端**：
   - API 端点作为客户端
   - 通过代理访问主体

**代码示例**：

```python
@app.route('/api/process_document', methods=['POST'])
def process_document():
    # ... 请求验证和解密 ...
    
    # 生成缓存键
    cache_key = sha256_hash(json.dumps(decrypted_data, sort_keys=True))
    
    # 检查缓存（代理行为）
    cached_result = check_cache(cache_key)
    if cached_result:
        # 缓存命中，直接返回缓存结果
        response = encrypt_response(cached_result, aes_key)
        return jsonify(response), 200
    
    # 缓存未命中，创建任务并添加到队列
    task_id = str(uuid.uuid4())
    task = {
        'id': task_id,
        'type': 'document',
        'data': decrypted_data,
        'cache_key': cache_key,
        'aes_key': aes_key
    }
    
    add_task_to_queue(task)
    
    # 返回任务 ID
    response = encrypt_response({'task_id': task_id}, aes_key)
    return jsonify(response), 202

# 缓存检查函数
def check_cache(cache_key):
    """检查是否有缓存的结果"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute(
        "SELECT result FROM cache WHERE key = ? AND expires_at > ?",
        (cache_key, int(time.time()))
    )
    
    result = cursor.fetchone()
    conn.close()
    
    if result:
        return json.loads(result[0])
    else:
        return None

# 存储缓存
def store_cache(cache_key, result, expires_in=86400):
    """存储结果到缓存"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    expires_at = int(time.time()) + expires_in
    
    cursor.execute(
        "INSERT OR REPLACE INTO cache (key, result, expires_at) VALUES (?, ?, ?)",
        (cache_key, json.dumps(result), expires_at)
    )
    
    conn.commit()
    conn.close()
```

### 优势

1. **性能优化**：避免重复计算，提高系统响应速度
2. **透明性**：客户端不需要了解缓存机制的细节
3. **控制访问**：代理可以控制对主体的访问，实现额外的功能（如缓存过期）
4. **资源节约**：减少对 OCR 和 LLM 服务的调用，节约资源

## 命令模式

命令模式用于封装任务处理请求，支持异步执行和状态跟踪。

### 实现方式

系统将任务封装为命令对象：

1. **命令**：
   - 任务对象作为命令
   - 包含执行所需的所有信息（任务类型、数据、ID 等）

2. **调用者**：
   - 工作线程作为调用者
   - 从队列获取命令并执行

3. **接收者**：
   - 处理函数作为接收者
   - 执行实际的处理逻辑

**代码示例**：

```python
# 创建命令（任务对象）
task = {
    'id': task_id,
    'type': 'document',
    'data': decrypted_data,
    'cache_key': cache_key,
    'aes_key': aes_key
}

# 添加命令到队列
add_task_to_queue(task)

# 调用者（工作线程）执行命令
def worker():
    while True:
        # 获取命令
        task = task_queue.get()
        try:
            # 根据命令类型选择接收者
            if task['type'] == 'document':
                # 接收者执行命令
                process_document_task(task)
            elif task['type'] == 'form':
                process_form_task(task)
            elif task['type'] == 'form_filling':
                process_form_filling_task(task)
        except Exception as e:
            update_task_status(task['id'], 'error', str(e))
        finally:
            task_queue.task_done()
```

### 优势

1. **解耦**：将请求发送者和接收者解耦
2. **可队列化**：命令可以存储在队列中，支持异步执行
3. **可撤销**：可以实现命令的撤销和重做（虽然当前系统未实现）
4. **状态跟踪**：可以跟踪命令的执行状态

## 装饰器模式

装饰器模式用于增强核心功能，如添加安全验证、错误处理等。

### 实现方式

系统使用 Python 的装饰器语法实现装饰器模式：

1. **核心组件**：
   - 核心功能函数（如 API 端点）

2. **装饰器**：
   - Flask 的路由装饰器（`@app.route`）
   - 自定义的错误处理装饰器

3. **增强功能**：
   - 路由映射
   - 请求解析
   - 错误捕获和处理

**代码示例**：

```python
# Flask 路由装饰器
@app.route('/api/process_document', methods=['POST'])
def process_document():
    # 核心功能
    # ...

# 自定义错误处理装饰器（假设实现）
def error_handler(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception as e:
            # 错误处理逻辑
            return jsonify({"error": str(e)}), 500
    return wrapper

# 使用自定义装饰器
@app.route('/api/task_status', methods=['POST'])
@error_handler
def get_task_status():
    # 核心功能
    # ...
```

### 优势

1. **功能增强**：在不修改核心代码的情况下增强功能
2. **关注点分离**：核心逻辑和增强功能分离
3. **可组合性**：多个装饰器可以组合使用
4. **可复用性**：装饰器可以应用于多个核心组件

## 适配器模式

适配器模式用于转换数据格式，使不同组件能够协同工作。

### 实现方式

系统在多个地方使用适配器模式转换数据格式：

1. **OCR 结果适配**：
   - 将 OCR 服务返回的结果转换为 LLM 处理所需的格式

2. **LLM 结果适配**：
   - 将 LLM 返回的文本解析为结构化的 JSON 数据

3. **响应格式适配**：
   - 将内部数据结构转换为 API 响应格式

**代码示例**：

```python
# OCR 结果适配
def extract_text_from_ocr_result(ocr_result):
    """从 OCR 结果中提取文本（适配器）"""
    try:
        # 检查 OCR 结果格式
        if 'text' not in ocr_result:
            raise Exception("OCR 结果格式错误")
        
        # 提取文本
        text = ocr_result['text']
        
        # 基本文本清理
        text = text.strip()
        
        return text
    except Exception as e:
        raise Exception(f"OCR 结果处理失败: {str(e)}")

# LLM 结果适配
def parse_document_result(llm_response):
    """解析文档处理的 LLM 响应（适配器）"""
    try:
        # 尝试解析 JSON 格式的响应
        if llm_response.strip().startswith('{') and llm_response.strip().endswith('}'):
            return json.loads(llm_response)
        
        # 尝试提取 JSON 部分
        json_match = re.search(r'```json\s*([\s\S]*?)\s*```', llm_response)
        if json_match:
            json_str = json_match.group(1)
            return json.loads(json_str)
        
        # 如果无法解析为 JSON，返回原始文本
        return {"text": llm_response, "parsed": False}
    except Exception as e:
        # 解析失败，返回错误信息和原始响应
        return {
            "error": f"解析失败: {str(e)}",
            "raw_response": llm_response,
            "parsed": False
        }
```

### 优势

1. **兼容性**：使不同接口的组件能够协同工作
2. **重用性**：可以重用现有组件，而不需要修改其接口
3. **灵活性**：可以适应不同的数据格式和接口要求
4. **封装变化**：将接口转换的复杂性封装在适配器中

## 总结

DocuSnap-Backend 系统应用了多种设计模式，这些模式共同构成了一个灵活、可扩展的架构：

1. **生产者-消费者模式**：实现异步任务处理
2. **策略模式**：根据任务类型选择处理策略
3. **工厂方法模式**：创建不同类型的提示
4. **代理模式**：实现缓存机制
5. **命令模式**：封装任务处理请求
6. **装饰器模式**：增强核心功能
7. **适配器模式**：转换数据格式

这些设计模式的应用体现了良好的软件设计原则，如单一职责、开闭原则、依赖倒置等，提高了代码的可维护性、可扩展性和灵活性。虽然系统中的设计模式实现相对简单，但已经能够有效支持系统的核心功能和性能需求。

通过更深入地应用这些设计模式，以及引入更多的设计模式（如观察者模式、模板方法模式等），可以进一步提高系统的质量和可扩展性。
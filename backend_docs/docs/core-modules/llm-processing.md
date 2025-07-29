# LLM 处理模块

LLM 处理模块是 DocuSnap-Backend 系统的核心智能组件，负责文本分析和信息提取。该模块与智谱 AI 的大语言模型服务交互，通过精心设计的提示工程，实现对文档内容的深度理解和结构化处理。

## 模块职责

LLM 处理模块的主要职责包括：

1. **提示构建**：根据任务类型和 OCR 结果构建适当的提示（Prompt）
2. **LLM API 调用**：与智谱 AI 的 LLM 服务交互，发送提示并接收响应
3. **响应解析**：解析 LLM 返回的响应，提取有用信息
4. **结果结构化**：将 LLM 分析结果转换为结构化数据格式
5. **错误处理**：处理 LLM 调用过程中的错误和异常情况

## 核心组件

### 1. 提示构建器

提示构建器负责根据任务类型和 OCR 结果构建适当的提示，引导 LLM 进行准确的文本分析和信息提取。系统为不同类型的任务（文档处理、表单处理、表单填充）设计了专门的提示模板。

**代码示例**：

```python
def build_document_prompt(ocr_text):
    """构建文档处理的提示"""
    # 从 prompts.py 获取文档处理提示模板
    prompt_template = DOCUMENT_PROMPT_TEMPLATE
    
    # 将 OCR 文本插入提示模板
    prompt = prompt_template.format(document_text='\n'.join(ocr_text))
    
    return prompt

def build_form_prompt(ocr_text):
    """构建表单处理的提示"""
    # 从 prompts.py 获取表单处理提示模板
    prompt_template = FORM_PROMPT_TEMPLATE
    
    # 将 OCR 文本插入提示模板
    prompt = prompt_template.format(form_text='\n'.join(ocr_text))
    
    return prompt

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
```

### 2. LLM API 客户端

LLM API 客户端负责与智谱 AI 的 LLM 服务交互，发送提示并接收响应。系统使用 `zhipuai` 库调用智谱 AI 的 API。

**代码示例**：

```python
def call_llm_api(prompt, max_tokens=4096):
    """调用 LLM API 处理提示"""
    try:
        # 调用智谱 AI 的 API
        response = zhipuai.model_api.invoke(
            model="chatglm_pro",
            prompt=prompt,
            temperature=0.7,
            max_tokens=max_tokens
        )
        
        # 检查响应状态
        if response['code'] == 200:
            return response['data']['choices'][0]['content']
        else:
            raise Exception(f"LLM API 调用失败: {response['msg']}")
    except Exception as e:
        raise Exception(f"LLM API 调用异常: {str(e)}")
```

### 3. 响应解析器

响应解析器负责解析 LLM 返回的响应，提取有用信息，并处理可能的格式问题。

**代码示例**：

```python
def parse_document_result(llm_response):
    """解析文档处理的 LLM 响应"""
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

def parse_form_result(llm_response):
    """解析表单处理的 LLM 响应"""
    # 类似于 parse_document_result，但针对表单结果
    # ...

def parse_form_filling_result(llm_response):
    """解析表单填充的 LLM 响应"""
    # 类似于 parse_document_result，但针对表单填充结果
    # ...
```

### 4. 结果格式化器

结果格式化器负责将解析后的 LLM 响应转换为系统需要的结构化数据格式，确保输出一致性。

**代码示例**：

```python
def format_document_result(parsed_result):
    """格式化文档处理结果"""
    # 确保结果包含必要的字段
    result = {
        "title": parsed_result.get("title", "未知标题"),
        "content": parsed_result.get("content", {}),
        "metadata": {
            "processed_at": int(time.time()),
            "source": "document_processing"
        }
    }
    
    return result

def format_form_result(parsed_result):
    """格式化表单处理结果"""
    # 类似于 format_document_result，但针对表单结果
    # ...

def format_form_filling_result(parsed_result):
    """格式化表单填充结果"""
    # 类似于 format_document_result，但针对表单填充结果
    # ...
```

## 提示工程

LLM 处理模块的核心是提示工程（Prompt Engineering），通过精心设计的提示模板引导 LLM 进行准确的文本分析和信息提取。系统为三种主要任务类型设计了专门的提示模板：

### 1. 文档处理提示

文档处理提示引导 LLM 分析文档内容，识别标题、段落、列表等结构，并提取关键信息。

**提示模板示例**：

```
你是一个专业的文档分析助手。请分析以下文档内容，提取关键信息并按照指定格式输出。

文档内容：
{document_text}

请提供以下信息：
1. 文档标题
2. 文档类型（如：报告、合同、通知等）
3. 主要内容摘要
4. 关键日期和数字
5. 重要人名和机构

请以JSON格式输出结果，包含以下字段：
- title: 文档标题
- document_type: 文档类型
- summary: 内容摘要（100-200字）
- key_dates: 关键日期列表，每项包含date（日期）和context（上下文）
- key_figures: 关键数字列表，每项包含figure（数字）和context（上下文）
- key_entities: 重要人名和机构列表，每项包含name（名称）和role（角色）
```

### 2. 表单处理提示

表单处理提示引导 LLM 识别表单结构，提取字段名称和对应的值。

**提示模板示例**：

```
你是一个专业的表单分析助手。请分析以下表单内容，提取所有字段及其值。

表单内容：
{form_text}

请执行以下任务：
1. 识别表单的类型和标题
2. 提取所有字段名称和对应的值
3. 对字段进行分类（个人信息、联系方式、其他信息等）

请以JSON格式输出结果，包含以下字段：
- form_title: 表单标题
- form_type: 表单类型
- fields: 字段列表，每个字段包含：
  - name: 字段名称
  - value: 字段值
  - category: 字段类别
- metadata: 表单元数据，包含表单ID、日期等信息（如果有）
```

### 3. 表单填充提示

表单填充提示引导 LLM 将用户提供的信息与表单字段匹配，生成填充后的表单数据。

**提示模板示例**：

```
你是一个专业的表单填充助手。请根据用户提供的信息，填充以下表单。

表单内容：
{form_text}

用户信息：
{user_data}

请执行以下任务：
1. 分析表单结构，识别所有需要填写的字段
2. 将用户提供的信息与表单字段进行匹配
3. 对于缺失的必填字段，标记为"缺失"
4. 对于可以推断的字段，尝试合理推断

请以JSON格式输出结果，包含以下字段：
- form_title: 表单标题
- filled_fields: 已填充的字段列表，每个字段包含：
  - name: 字段名称
  - value: 填充的值
  - source: 值的来源（"user_provided", "inferred", "default"）
- missing_fields: 缺失的必填字段列表
- complete: 表单是否完整填写（布尔值）
```

## 工作流程

LLM 处理模块的工作流程如下：

1. **接收输入**：
   - 从任务处理模块接收 OCR 处理后的文本
   - 根据任务类型确定处理策略

2. **构建提示**：
   - 选择适当的提示模板
   - 将 OCR 文本插入提示模板
   - 添加任务特定的指令和格式要求

3. **调用 LLM API**：
   - 发送提示到智谱 AI 的 LLM 服务
   - 设置适当的参数（温度、最大令牌数等）
   - 接收 LLM 的响应

4. **解析响应**：
   - 解析 LLM 返回的文本
   - 提取 JSON 或其他结构化数据
   - 处理可能的格式问题

5. **格式化结果**：
   - 将解析后的结果转换为标准格式
   - 确保输出一致性
   - 添加元数据和处理信息

6. **返回结果**：
   - 将格式化后的结果返回给任务处理模块
   - 处理和报告任何错误

## 与 LLM 服务的集成

DocuSnap-Backend 使用智谱 AI 的 LLM 服务进行文本分析和信息提取。选择智谱 AI 的主要原因包括：

1. **中文处理能力**：智谱 AI 的模型对中文有较好的优化，适合处理中文文档和表单
2. **结构化输出能力**：支持生成结构化的 JSON 输出，适合提取表单字段和值
3. **API 接口和集成便利性**：提供简洁易用的 API 接口和 Python SDK

集成方式是通过 `zhipuai` 库调用智谱 AI 的 API，发送提示并接收响应。

## 错误处理

LLM 处理模块实现了全面的错误处理机制：

1. **API 调用错误**：处理 LLM 服务不可用或响应错误的情况
2. **响应解析错误**：处理 LLM 响应格式不符合预期的情况
3. **超时处理**：处理 LLM 服务响应超时的情况
4. **结果验证**：验证 LLM 结果是否符合预期格式和内容要求

## 模块接口

LLM 处理模块提供以下主要接口：

1. **对外接口**：
   - `process_with_llm`：使用 LLM 处理文本并返回结果

2. **对内接口**：
   - `build_document_prompt`：构建文档处理提示
   - `build_form_prompt`：构建表单处理提示
   - `build_form_filling_prompt`：构建表单填充提示
   - `call_llm_api`：调用 LLM API
   - `parse_document_result`：解析文档处理结果
   - `parse_form_result`：解析表单处理结果
   - `parse_form_filling_result`：解析表单填充结果

## 性能优化

LLM 处理模块的性能优化措施包括：

1. **提示优化**：精心设计提示模板，减少不必要的令牌消耗
2. **参数调优**：根据任务需求调整 LLM 调用参数（温度、最大令牌数等）
3. **响应缓存**：通过任务处理模块的缓存机制，避免重复调用 LLM API
4. **错误重试**：对临时性错误实现自动重试机制

## 扩展性

LLM 处理模块的扩展性体现在：

1. **支持多种 LLM 服务**：设计支持未来集成其他 LLM 服务
2. **可扩展的提示模板**：可以轻松添加和修改提示模板，支持新的任务类型
3. **结果后处理扩展**：可以添加更多结果验证和优化功能
4. **提示策略优化**：可以实现更复杂的提示策略，如多轮对话或链式思考

通过这些设计和实现，LLM 处理模块为 DocuSnap-Backend 系统提供了强大的文本分析和信息提取能力，是系统智能处理文档和表单的核心组件。
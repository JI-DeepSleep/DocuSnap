# 安全加密模块

安全加密模块是 DocuSnap-Backend 系统的关键安全组件，负责实现端到端加密和请求验证，保护敏感文档和表单数据的传输安全。该模块采用 RSA 和 AES 混合加密方案，结合哈希验证机制，提供全面的数据安全保障。

## 模块职责

安全加密模块的主要职责包括：

1. **密钥管理**：生成、存储和管理 RSA 密钥对
2. **请求解密**：解密客户端发送的加密请求
3. **响应加密**：加密返回给客户端的响应数据
4. **请求验证**：验证请求的完整性和真实性
5. **安全配置**：管理系统的安全相关配置

## 核心组件

### 1. RSA 加密/解密器

RSA 加密/解密器负责处理非对称加密操作，主要用于密钥交换。系统使用 RSA 加密保护 AES 密钥的传输安全。

**代码示例**：

```python
def load_private_key():
    """加载 RSA 私钥"""
    try:
        with open(PRIVATE_KEY_PATH, 'rb') as f:
            private_key = RSA.import_key(f.read())
        return private_key
    except Exception as e:
        raise Exception(f"加载私钥失败: {str(e)}")

def rsa_decrypt(encrypted_data, private_key):
    """使用 RSA 私钥解密数据"""
    try:
        cipher = PKCS1_OAEP.new(private_key)
        decrypted_data = cipher.decrypt(base64.b64decode(encrypted_data))
        return decrypted_data
    except Exception as e:
        raise Exception(f"RSA 解密失败: {str(e)}")
```

### 2. AES 加密/解密器

AES 加密/解密器负责处理对称加密操作，用于加密和解密实际的请求和响应数据。系统使用 AES 加密提供高效的数据加密。

**代码示例**：

```python
def aes_decrypt(encrypted_data, key):
    """使用 AES 密钥解密数据"""
    try:
        # 从 Base64 解码加密数据
        encrypted_data_bytes = base64.b64decode(encrypted_data)
        
        # 提取 IV（前 16 字节）
        iv = encrypted_data_bytes[:16]
        ciphertext = encrypted_data_bytes[16:]
        
        # 创建 AES 解密器
        cipher = AES.new(key, AES.MODE_CBC, iv)
        
        # 解密数据
        padded_data = cipher.decrypt(ciphertext)
        
        # 移除填充
        unpadder = padding.PKCS7(AES.block_size).unpadder()
        data = unpadder.update(padded_data) + unpadder.finalize()
        
        return data.decode('utf-8')
    except Exception as e:
        raise Exception(f"AES 解密失败: {str(e)}")

def aes_encrypt(data, key):
    """使用 AES 密钥加密数据"""
    try:
        # 生成随机 IV
        iv = get_random_bytes(16)
        
        # 创建 AES 加密器
        cipher = AES.new(key, AES.MODE_CBC, iv)
        
        # 添加填充
        padder = padding.PKCS7(AES.block_size).padder()
        padded_data = padder.update(data.encode('utf-8')) + padder.finalize()
        
        # 加密数据
        ciphertext = cipher.encrypt(padded_data)
        
        # 组合 IV 和密文，并进行 Base64 编码
        encrypted_data = base64.b64encode(iv + ciphertext).decode('utf-8')
        
        return encrypted_data
    except Exception as e:
        raise Exception(f"AES 加密失败: {str(e)}")
```

### 3. 哈希验证器

哈希验证器负责生成和验证数据的哈希值，确保数据的完整性和真实性。系统使用 SHA256 哈希算法进行验证。

**代码示例**：

```python
def sha256_hash(data):
    """计算数据的 SHA256 哈希值"""
    try:
        if isinstance(data, str):
            data = data.encode('utf-8')
        return hashlib.sha256(data).hexdigest()
    except Exception as e:
        raise Exception(f"计算哈希失败: {str(e)}")

def verify_signature(data, signature):
    """验证数据的签名（哈希值）"""
    computed_hash = sha256_hash(data)
    return computed_hash == signature
```

### 4. 请求处理器

请求处理器负责解密和验证客户端请求，以及加密返回给客户端的响应。

**代码示例**：

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
        if not verify_signature(data, signature):
            raise Exception("签名验证失败")
        
        return json.loads(data), aes_key
    except Exception as e:
        raise Exception(f"请求解密失败: {str(e)}")

def encrypt_response(data, aes_key):
    """加密响应数据"""
    try:
        # 将数据转换为 JSON 字符串
        json_data = json.dumps(data, ensure_ascii=False)
        
        # 使用 AES 密钥加密数据
        encrypted_data = aes_encrypt(json_data, aes_key)
        
        # 计算签名
        signature = sha256_hash(json_data)
        
        return {
            "encrypted_data": encrypted_data,
            "signature": signature
        }
    except Exception as e:
        raise Exception(f"响应加密失败: {str(e)}")
```

## 加密方案设计

DocuSnap-Backend 采用 RSA 和 AES 混合加密方案，结合了两种加密技术的优势：

1. **RSA 非对称加密**：
   - 用于安全传输 AES 密钥
   - 服务器持有私钥，客户端使用公钥加密
   - 解决了密钥分发问题

2. **AES 对称加密**：
   - 用于加密实际的请求和响应数据
   - 提供高效的数据加密
   - 支持大量数据的加密

3. **SHA256 哈希验证**：
   - 验证数据的完整性
   - 防止数据被篡改
   - 提供额外的安全保障

这种混合加密方案平衡了安全性和性能，适合处理敏感文档和表单数据的传输安全需求。

## 工作流程

安全加密模块的工作流程如下：

### 请求处理流程

1. **接收加密请求**：
   - 客户端使用服务器的 RSA 公钥加密 AES 密钥
   - 客户端使用 AES 密钥加密请求数据
   - 客户端计算请求数据的 SHA256 哈希值作为签名
   - 客户端发送加密的 AES 密钥、加密的请求数据和签名

2. **解密和验证**：
   - 服务器使用 RSA 私钥解密 AES 密钥
   - 服务器使用 AES 密钥解密请求数据
   - 服务器计算解密后数据的 SHA256 哈希值
   - 服务器验证计算的哈希值与签名是否匹配

3. **处理请求**：
   - 如果验证通过，服务器处理解密后的请求
   - 如果验证失败，服务器返回错误响应

### 响应处理流程

1. **准备响应**：
   - 服务器准备响应数据
   - 服务器将响应数据转换为 JSON 格式

2. **加密响应**：
   - 服务器使用之前解密得到的 AES 密钥加密响应数据
   - 服务器计算响应数据的 SHA256 哈希值作为签名

3. **发送加密响应**：
   - 服务器发送加密的响应数据和签名给客户端
   - 客户端使用 AES 密钥解密响应数据
   - 客户端验证响应数据的完整性

## 密钥管理

安全加密模块实现了以下密钥管理机制：

1. **RSA 密钥对生成**：
   - 使用 `genKeyPairs.sh` 脚本生成 RSA 密钥对
   - 私钥保存在服务器，公钥分发给客户端

2. **密钥存储**：
   - 私钥存储在服务器的安全位置
   - 访问权限受到严格控制

3. **AES 密钥生成**：
   - 每个请求使用新的随机 AES 密钥
   - 增强安全性，防止重放攻击

## 安全措施

安全加密模块实现了多层安全措施：

1. **端到端加密**：
   - 数据在传输过程中始终保持加密状态
   - 只有合法的接收方可以解密数据

2. **完整性验证**：
   - 使用 SHA256 哈希验证数据完整性
   - 防止数据被篡改或损坏

3. **参数验证**：
   - 验证请求参数的格式和内容
   - 防止恶意输入和注入攻击

4. **错误处理**：
   - 安全的错误处理机制
   - 不泄露敏感信息的错误消息

## 模块接口

安全加密模块提供以下主要接口：

1. **对外接口**：
   - `decrypt_request`：解密和验证客户端请求
   - `encrypt_response`：加密返回给客户端的响应

2. **对内接口**：
   - `load_private_key`：加载 RSA 私钥
   - `rsa_decrypt`：使用 RSA 私钥解密数据
   - `aes_decrypt`：使用 AES 密钥解密数据
   - `aes_encrypt`：使用 AES 密钥加密数据
   - `sha256_hash`：计算数据的 SHA256 哈希值
   - `verify_signature`：验证数据的签名

## 安全最佳实践

安全加密模块遵循以下安全最佳实践：

1. **使用标准加密算法**：
   - RSA 用于非对称加密
   - AES 用于对称加密
   - SHA256 用于哈希验证

2. **安全的密钥管理**：
   - 私钥安全存储
   - 每个请求使用新的 AES 密钥
   - 密钥长度符合安全标准

3. **完整的验证机制**：
   - 验证请求的完整性和真实性
   - 多层验证确保安全性

4. **安全的错误处理**：
   - 不泄露敏感信息
   - 提供适当的错误消息

## 扩展性

安全加密模块的扩展性体现在：

1. **支持多种加密算法**：
   - 设计支持未来升级或更换加密算法
   - 可以根据安全需求调整参数

2. **可配置的安全策略**：
   - 可以根据需求调整安全级别
   - 支持添加新的安全措施

3. **密钥轮换机制**：
   - 支持定期轮换 RSA 密钥对
   - 增强长期安全性

通过这些设计和实现，安全加密模块为 DocuSnap-Backend 系统提供了全面的数据安全保障，确保敏感文档和表单数据的传输安全。
# Respostas por Pedro Amaral Fontes de Sales:


## 1. Kernel e bootloader

- Bootar a máquina "física" (pelo virtual box)
- Ainda no menu de boot, selecionar a opção primária de boot e apertar a tecla "e" para editar o modo de boot
- Na linha que se inicia com "linux ($root)...", procure o parâmetro "ro" (read-only) e altere para "rw init=/sysroot/bin/sh". 
- Aperte ctrl + X para sair. O SO irá iniciar em single-user mode.
- No terminal que irá aparecer, rode o comando "chroot /sysroot" para montar o sistema de arquivos root.
- Rode o comando `passwd root` para alterar a senha para o usuário root.
- Rode o comando `touch /.autorelabel` para provocar o relabeling automatico do sistema de arquivos durante o próximo boot.
- Rode o comando `exit`  e em seguida o comando `reboot`. A máquina irá reiniciar e você poderá fazer login com o usuário root utilizando a senha que você acabou de redefinir.
- Logado como o usuário root execute o comando `usermod -aG wheel vagrant`, isso irá restaurar a permissão no sudo para o usuário.

## 2. Criação deo usuários 

Quando se cria um novo usuário, para poder especificar o seu grupo primário durante a criação, é necessário que o grupo já
exista, portanto:
- Rode o comando `groupadd -g 2222 getup`. Esse comando irá criar o grupo getup com GID=2222
- Rode o comando `useradd -u 1111 -g 2222 -G bin getup`. Esse comando irá criar o usuário getup com UID=1111, cujo grupo primário é o grupo getup (de GID=2222), e já irá adicionar esse usuário ao grupo bin.
- Rode o comando `visudo` para alterar o arquivo de configurações relativas ao privilégio sudo.
- Ao arquivo, adicione a linha "getup   ALL=(ALL)   NOPASSWD: ALL" para conferir permissão sudo sem necessidade de senha ao usuário getup. (Os comentários do arquivo indicam o local apropriado para coloar a linha)

## 3. SSH

Se o passo 3.1 for executado antes do passo 3.2, não será possível fazer a cópia das credenciais utilizando o comando ssh-copy-id, pois ele necessita autenticação por senha. Por isso, aqui os passos são listados em ordem trocada. Se necessário, o passo 3.1 por ser executado primeiro, porém será necessário copiar a chave por outro meio.
    
### 3.2 Criação de chaves

- Na máquina client, execute o comando `ssh-keygen -t ecdsa`
- Ainda na máquina cliente, execute `ssh-copy-id vagrant@<ip-da-sua-vm>` (caso não tenha ficado claro, <ip-da-sua-vm> deve ser substituído pelo endereço de IP da sua máquina virtual)

### 3.1 Autenticação confiável

- Edite o arquivo /etc/ssh/sshd_config
- No arquivo, há a seguinte linha "PasswordAuthentication yes". Altere-a para "PasswordAuthentication no" e adicione a seguinte linha "PubkeyAuthentication yes". Salve o arquivo.
- Para que as alterações tenham efeito, reinicie o serviço ssh com o comando `systemctl restart sshd`.

### 3.3 Análise de logs e configurações ssh

A transferencia de credenciais via ssh-copy-id exige autenticação por senha, portanto, logado no usuário root, execute `passwd devel` e defina uma nova senha para o usuário devel.         

A chave é um arquivo compactado com o gzip e codificado em base 64. Para usá-lo:
- Use o comando `base64 -d id_rsa-desafio-linux-devel.gz.b64 > id_rsa-desafio-linux-devel.gz` para decodificar da base 64 e salvar o resultado em um arquivo .gz.
- Use o comando `gzip -d id_rsa-desafio-linux-devel` para descompactar as credenciais.
        
O local correto para armazenar chaves ssh é na pasta ~/.ssh, portanto mova a chave para lá com: `mv id_rsa-desafio-linux-devel ~/.ssh/id_rsa-desafio-linux-devel`. 
        
A chave foi criada em um sistema que usa o caractere especial carriage return(^M)  em adição da quebra de linha(\n).
É necessário converter a quebra de linha para um formato aceitável a sistemas unix. A aplicação dos2unix faz isso, porém essa substituição pode ser feita manualmente.
- `dos2unix ~/.ssh/id_rsa-desafio-linux-devel` para converter as quebras de linha ao formato adequado a sistemas unix.
- `ssh-keygen -y -f ~/.ssh/id_rsa-desafio-linux-devel > ~/.ssh/id_rsa-desafio-linux-devel.pub` para gerar a chave pública relativa à nossa chave privada, e salvar no arquivo de nome apropriado.

Execute o comando `ssh-copy-id -i ~/.ssh/id_rsa-desafio-linux-devel.pub devel@ip-da-vm` para transferir as credenciais. Para executar esse comando é necessário que a autenticação com senha via ssh esteja habilitada.

Por fim, a pasta authorized_keys, do usuário devel, não tem o conjunto exijido de permissões, portanto, é necessário corrijir as permissões para que a autenticação seja bem sucedida. Logado como o usuário devel (pode fazer conexão via ssh e autenticar com senha, conectar ao usuário vagrant e dele logar ao usuário devel, etc) execute o comando `chmod 600 ~/.ssh/authorized_keys`.
        
A partir de agora o login utilizando a credencial fornecida deve ser possível.

## 4. Systemd

Rode o comando `systemctl start nginx` e verá que ocorre um erro. O próprio systemctl sugere que você rode o comando `systemctl status nginx/service` para obter mais informações. Executando o comando, vemos que ele indica que a diretiva "root" recebeu um número inválido de argumentos na linha 45, no arquivo /etc/nginx/nginx.conf. Utilizando um editor de texto, adicione um ponto e virgula (";") ao final da linha 42, onde a diretiva "root" é declarada.

Executando novamente o comando `systemctl start nginx` vemos que ele continua falhando. Olhando o log fornecido pelo comando `systemctl status nginx.service` novamente, vemos que um processo desencadeado pelo systemctl retornou um código de erro. O comando que provocou o erro foi "ExecStart=/usr/sbin/nginx -BROKEN". Utilizando um editor de texto, altere o arquivo que define o serviço do ngix e remova o parâmetro "-BROKEN". O arquivo em questão é "/usr/lib/systemd/system/nginx.service".

Executando o comando `systemctl start nginx` uma terceira vez, vemos que o serviço é iniciado com sucesso. Se tentarmos executar o comando `curl http://127.0.0.1`, entretanto, vemos que ocorre um erro: "curl: (7) Failed to connect to 127.0.0.1 port 80: Conenction refused". Se voltarmos ao arquivo /etc/nginx/nginx.conf vemos que o servidor foi configurado, nas linhas 39 e 40, para escutar na porta 90. Altere o arquivo, para que o servidor passe a escutar na porta 80. Reinicie o serviço com `systemctl restart nginx`.

O comando `curl http://127.0.0.1` retorna o seguinte texto: "Duas palavrinhas pra você: para, béns!"

## 5. SSL
    
Por falta de tempo e pela dificuldade, esse desafio foi deixado de lado 
    
## 6. Rede
    
### 6.1 Firewall
O comando funcionou sem problemas, não foi necessário fazer nenhuma alteração de qualquer natureza no sistema
    
### 6.2 HTTP
```
{
    "Content-Length": "89", 
    "Content-Type": "application/json", 
    "hello": "world"
}
```

### 6.3 Logs

Utilizando um editor de texto, crie um arquivo chamado "nginx" na pasta /etc/logrotate.d .Na primeira linha do arquivo adicione "/var/log/nginx/\* {}", entre chaves podem ser colocadas as opções de rotação. O "/\*" após o diretório dos logs, indica que a politica de rotação de logs se aplica a todos os arquivos de log na pasta. Abaixo segue um exemplo de configuração:

```
/var/log/nginx/* {
    weekly
    rotate 3
    size 10M
    compress
    delaycompress
}
```

## 7. LVM
    
### 7.2 Criar Partição LVM
        
- Execute o comando `cfdisk /dev/sdb` e crie uma nova partição primária, com 5G de tamanho.
- Execute o comando `pvcreate /dev/sdb2` para criar um novo PV.
- Execute o comando `vgcreate desafio-linux_vg /dev/sdb2` para criar um novo grupo de volumes chamado desafio-linux_vg.
- Execute o comando `lvcreate -n desafio-linux_lv -L 5000M desafio-linux_vg` para criar um novo volume lógico chamado desafio-linux_lv com 5G de tamanho.
- Por fim, execute o comando `mkfs.ext4 /dev/desafio-linux_vg/desafio-linux_lv` para criar o sistema de arquivos.  

### 7.1 Expandir partição LVM
- Execute o comando `cfdisk /dev/sdb` e crie uma nova partição primária, com os 4G de espaço livre restantes.
- Execute o comando `vgextend data_vg /dev/sdb3` para adicionar esses 4G ao VG.      
- Execute o comando `lvextend -L +4000M /dev/data_vg/data_lv` para expandir o volume lógico
- Execute o comando `resize2fs /dev/data_vg/data_lv` para expandir o sistema de arquivos.

### 7.3 Criar partição XFS
       
- Repita os passos da etapa 7.2 (adequando o nome dos dispositivos, pv's, vg's e lv's) até o ultimo comando antes da formatação.      
- Execute `dnf install xfsprogs` para instalar o XFS.
- Execute `mkfs.xfs /caminho/para/lv` para formatar o lv criado.
        

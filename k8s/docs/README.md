sloučení kubeconfig windows powershell
$Env:KUBECONFIG=("C:\Users\<username>\.kube\config;C:\Users\<username>\Documents\kubeconfig.yaml"); kubectl config view --merge --flatten | Out-File "C:\Users\<username>\.kube\config_marged"

# Polygon Network Account Setup & Deployment Script
# Automates RPC endpoint configuration, wallet setup, and smart contract deployment

Write-Host "🔷 Polygon Network Setup Automation" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Configuration
$polygonMainnetRPC = "https://polygon-rpc.com"
$polygonTestnetRPC = "https://rpc-mumbai.maticvigil.com"
$alchemyApiKey = "<YOUR_ALCHEMY_KEY>"  # Replace with actual key
$environment = "testnet"  # Change to "mainnet" for production

# Create Polygon config file
$polygonConfig = @"
{
  "networks": {
    "mainnet": {
      "rpc": "$polygonMainnetRPC",
      "chainId": 137,
      "explorer": "https://polygonscan.com"
    },
    "testnet": {
      "rpc": "$polygonTestnetRPC",
      "chainId": 80001,
      "explorer": "https://mumbai.polygonscan.com"
    }
  },
  "deployedContracts": {
    "stablecoinFactory": null,
    "treasuryWallet": null,
    "mpcVault": null,
    "nvqlink": null
  },
  "settings": {
    "gasEstimate": "auto",
    "slippage": 0.5,
    "confirmations": 5
  }
}
"@

# Create config directory if it doesn't exist
$configDir = "$PSScriptRoot\..\config"
if (!(Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    Write-Host "✅ Created config directory: $configDir" -ForegroundColor Green
}

# Save polygon config
$configPath = "$configDir\polygon.config.json"
$polygonConfig | Out-File -FilePath $configPath -Encoding UTF8 -Force
Write-Host "✅ Polygon config saved: $configPath" -ForegroundColor Green

# Create wallet setup script
$walletScript = @"
#!/usr/bin/env node
// Polygon Wallet & Smart Contract Deployment

const ethers = require('ethers');

async function setupPolygonWallet() {
  // Generate new wallet
  const wallet = ethers.Wallet.createRandom();
  console.log('📝 Generated Wallet:');
  console.log('Address:', wallet.address);
  console.log('Private Key:', wallet.privateKey);
  
  // Connect to Polygon testnet
  const provider = new ethers.providers.JsonRpcProvider('$polygonTestnetRPC');
  const connectedWallet = wallet.connect(provider);
  
  console.log('\n🔗 Connected to Polygon Testnet (Mumbai)');
  console.log('Network:', await provider.getNetwork());
  
  // Check balance
  const balance = await provider.getBalance(wallet.address);
  console.log('Balance:', ethers.utils.formatEther(balance), 'MATIC');
  
  return wallet;
}

// Run setup
setupPolygonWallet().catch(console.error);
"@

$scriptPath = "$configDir\deploy-polygon.js"
$walletScript | Out-File -FilePath $scriptPath -Encoding UTF8 -Force
Write-Host "✅ Wallet deployment script created: $scriptPath" -ForegroundColor Green

# Create environment variables file
$envContent = @"
# Polygon Network Configuration
POLYGON_RPC_URL=$polygonTestnetRPC
POLYGON_CHAIN_ID=80001
POLYGON_EXPLORER=https://mumbai.polygonscan.com

# Alchemy (optional, more reliable RPC)
ALCHEMY_API_KEY=$alchemyApiKey

# Wallet (NEVER commit this - keep in .env.local)
POLYGON_PRIVATE_KEY=<YOUR_PRIVATE_KEY>
POLYGON_WALLET_ADDRESS=<YOUR_WALLET_ADDRESS>

# Stablecoin Factory
STABLECOIN_FACTORY_ADDRESS=null
STABLECOIN_DECIMALS=18
STABLECOIN_SYMBOL=WEALTH

# Stripe Treasury Bridge
STRIPE_TREASURY_ACCOUNT=<YOUR_STRIPE_ACCOUNT>
STRIPE_ISSUING_CARD_PROGRAM=<YOUR_PROGRAM_ID>
"@

$envPath = "$PSScriptRoot\..\config\.env.polygon"
$envContent | Out-File -FilePath $envPath -Encoding UTF8 -Force
Write-Host "✅ Environment config created: $envPath" -ForegroundColor Green
Write-Host "⚠️  IMPORTANT: Update .env.polygon with your private keys (never commit!)" -ForegroundColor Yellow

# Create deployment checklist
$checklist = @"
# Polygon Deployment Checklist

## Prerequisites
- [ ] Alchemy Account (free tier available)
- [ ] MetaMask wallet with testnet funds
- [ ] Private key backed up securely
- [ ] Stripe Treasury account linked

## Testnet Deployment (Mumbai)
- [ ] Deploy Stablecoin Factory contract
- [ ] Mint test tokens
- [ ] Create treasury wallet
- [ ] Test token transfers
- [ ] Verify on PolygonScan

## Mainnet Deployment (Production)
- [ ] Audit smart contracts
- [ ] Secure private keys (hardware wallet recommended)
- [ ] Deploy with mainnet RPC
- [ ] Set mint/burn limits
- [ ] Enable Stripe bridges

## Post-Deployment
- [ ] Monitor gas fees
- [ ] Track stablecoin circulation
- [ ] Set up webhooks for transactions
- [ ] Configure rate limiting
- [ ] Enable 2FA on all wallet services
"@

$checklistPath = "$configDir\POLYGON_DEPLOYMENT_CHECKLIST.md"
$checklist | Out-File -FilePath $checklistPath -Encoding UTF8 -Force
Write-Host "✅ Deployment checklist: $checklistPath" -ForegroundColor Green

Write-Host "`n🎯 Polygon Setup Summary" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host "✅ Config file: $configPath"
Write-Host "✅ Wallet script: $scriptPath"
Write-Host "✅ Environment: $envPath"
Write-Host "✅ Checklist: $checklistPath"
Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Update .env.polygon with your Alchemy API key"
Write-Host "2. Generate wallet: node $scriptPath"
Write-Host "3. Get testnet MATIC from faucet: https://faucet.polygon.technology/"
Write-Host "4. Deploy contracts (coming next)"
Write-Host "`n✨ Ready for Polygon testnet deployment!" -ForegroundColor Green

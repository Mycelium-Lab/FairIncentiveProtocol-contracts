# FairProtocolContracts

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```

# Tokens
### Виды эмиссий:

`Capped - C` - обязательно устанавливается `max supply`, при этом возможность установить `initial supply` и можно минтить до `max supply`.

`Fixed -F` - устанавливается обязательно `initial supply` и больше нельзя наминтить.

`Unlimited -U` - можно минтить сколько угодно, нет `max supply`, но можно установить `initial supply`.

### Дополнения:

`Pausable - P` - возможность остановить критические функции в контракте.

`Burnable - B` - возможность сжигать монеты.

`Blacklist - Bl` - возможность добавлять пользователей в черный список, что запретит им пользоваться контрактом.

`Recoverable - R` - возможность возвращать любой токен, который был отправлен на контракт.

`Verified on Etherscan` 

### Название контрактов:

{Стандарт}{Тип эмиссии}{...Дополнения}.sol

ERC20CP.sol - ERC-20 Capped Pausable

ERC20CPB.sol - ERC-20 Capped Pausable Burnable

ERC20CPBBl.sol - ERC-20 Capped Pausable Blacklist

ERC20CPBBl.sol - ERC-20 Capped Pausable Recoverable

ERC20CPBBl.sol - ERC-20 Capped Pausable Burnable Blacklist

ERC20CPBBlR.sol - ERC-20 Capped Pausable Burnable Recoverable

ERC20CPBlR - ERC-20 Capped Pausable Blacklist Recoverable

ERC20CPBBlBlR.sol - ERC-20 Capped Pausable Burnable Blacklist Recoverable

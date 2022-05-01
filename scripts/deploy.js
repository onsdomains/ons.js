const hre = require('hardhat');
async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);
  console.log('Account balance:', (await deployer.getBalance()).toString());
  let BaseContract;
  let ControllerContract;
  let TopLevelDomain;
  let ListsController;
  let AdminController;
  let ResolverController;
  let TextResolver;
  let NFTResolver;
  let PublicResolver;
  let VerifyResolver;
  let TextFilters;
  let ContractAddressBook;
  let DummyERC721;

  BaseContract = await hre.ethers.getContractFactory('ONSRegister');
  TopLevelDomain = await hre.ethers.getContractFactory('TopLevelDomain');
  ListsController = await hre.ethers.getContractFactory('ListsController');
  AdminController = await hre.ethers.getContractFactory('AdminController');
  ControllerContract = await hre.ethers.getContractFactory('RegisterControllerV3');
  ResolverController = await hre.ethers.getContractFactory('ResolverController');
  TextResolver = await hre.ethers.getContractFactory('TextResolver');
  NFTResolver = await hre.ethers.getContractFactory('NFTResolver');
  PublicResolver = await hre.ethers.getContractFactory('PublicResolver');
  VerifyResolver = await hre.ethers.getContractFactory('VerifyResolver');
  TextFilters = await hre.ethers.getContractFactory('TextFilters');
  ContractAddressBook = await hre.ethers.getContractFactory('ContractAddressBook');
  DummyERC721 = await ethers.getContractFactory('DummyERC721');

  BaseContract = await BaseContract.deploy();
  AdminController = await AdminController.deploy();
  TopLevelDomain = await TopLevelDomain.deploy('.ons');
  ListsController = await ListsController.deploy(AdminController.address);
  DummyERC721 = await DummyERC721.deploy('https://api.com/');
  console.log(BaseContract.address);
  ControllerContract = await ControllerContract.deploy(
    BaseContract.address,
    TopLevelDomain.address,
    ListsController.address,
  );
  ResolverController = await ResolverController.deploy();
  TextFilters = await TextFilters.deploy();
  ContractAddressBook = await ContractAddressBook.deploy();

  TextResolver = await TextResolver.deploy(ResolverController.address);
  VerifyResolver = await VerifyResolver.deploy(BaseContract.address, ResolverController.address);

  NFTResolver = await NFTResolver.deploy(BaseContract.address, ResolverController.address);
  PublicResolver = await PublicResolver.deploy(
    BaseContract.address,
    TextResolver.address,
    NFTResolver.address,
    VerifyResolver.address,
    TextFilters.address,
  );

  await BaseContract.deployed();
  console.log('BaseContract Contract address:', BaseContract.address);
  await TopLevelDomain.deployed();
  console.log('TopLevelDomain Contract address:', TopLevelDomain.address);
  await ListsController.deployed();
  console.log('ListsController Contract address:', ListsController.address);
  await AdminController.deployed();
  console.log('AdminController Contract address:', AdminController.address);
  await ControllerContract.deployed();
  console.log('ControllerContract Contract address:', ControllerContract.address);
  await ResolverController.deployed();
  console.log('ResolverController Contract address:', ResolverController.address);
  await TextResolver.deployed();
  console.log('TextResolver Contract address:', TextResolver.address);
  await NFTResolver.deployed();
  console.log('NFTResolver Contract address:', NFTResolver.address);
  await PublicResolver.deployed();
  console.log('PublicResolver Contract address:', PublicResolver.address);
  await VerifyResolver.deployed();
  console.log('VerifyResolver Contract address:', VerifyResolver.address);
  await TextFilters.deployed();
  console.log('TextFilters Contract address:', TextFilters.address);
  await ContractAddressBook.deployed();
  console.log('ContractAddressBook Contract address:', ContractAddressBook.address);
  await DummyERC721.deployed();
  console.log('DummyERC721 Contract address:', DummyERC721.address);

  await BaseContract.addController(ControllerContract.address);
  console.log('ControllerContract was added to BaseContract');
  await AdminController.addController(ControllerContract.address);
  console.log('ControllerContract was added to AdminController');
  await ResolverController.addController(PublicResolver.address);
  console.log('PublicResolver was added to ResolverController');
  await TextFilters.permittingText('com.twitter');
  console.log('com.twitter was added to TextFilters');
  await DummyERC721.mint(10);
  console.log('minted 10 dummy NFTs');
  await ListsController.setDomainPrice(0, [1, 2, 3, 4, 5, 6], [2000, 1000, 500, 100, 60, 40]);
  console.log('Main Domain Price was set!');
  await ListsController.setDiscountPrice(0, [1, 2, 3, 4, 5, 6], [1000, 500, 250, 50, 20, 5]);
  console.log('Discount Domain Price was set!');

  await ContractAddressBook.setMultiContractAddress(
    [
      'BaseContract',
      'TopLevelDomain',
      'ListsController',
      'AdminController',
      'ControllerContract',
      'ResolverController',
      'TextResolver',
      'NFTResolver',
      'PublicResolver',
      'VerifyResolver',
      'TextFilters',
      'DummyERC721',
    ],
    ['NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL'],
    [
      BaseContract.address,
      TopLevelDomain.address,
      ListsController.address,
      AdminController.address,
      ControllerContract.address,
      ResolverController.address,
      TextResolver.address,
      NFTResolver.address,
      PublicResolver.address,
      VerifyResolver.address,
      TextFilters.address,
      DummyERC721.address,
    ],
  );
  console.log('Added All contracts to the ContractAddress Book');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

<?php
namespace App\LandingPage\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class LandingPageController extends AbstractController
{
    public function __construct(

    ) {
    }

    #[Route('/', name: 'landing_page')]
    public function renderLandingPage() : Response
    {
        return $this->render('@landing_page/landing_page.html.twig');
    }
}
